// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
* @title TicketNFT
* @notice ERC1155 implementation for multi-tier event tickets
* @dev Cloned per event via EventFactory
*/
contract TicketNFT is ERC1155, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant ORGANIZER_ROLE = keccak256("ORGANIZER");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER");

    enum EventStatus { 
        Setup, // Initial state, configuring tiers
        Live, // Sales active
        Ended, // Event completed
        Cancelled // Event cancelled, refunds enabled
    }

    struct TicketTier {
        uint256 maxSupply;
        uint256 minted;
        uint256 price;
        bool exists;
    }

    address public factory;
    address public organizer;

    uint256 public eventId;
    uint256 public eventDate;
    string public eventName;

    // Supported payment tokens (address(0) = native token)
    mapping(address => bool) public acceptedTokens;

    // tierdId => TicketTier
    mapping(uint256 => TicketTier) public tiers;

    // user => tierId => used count
    mapping(address => mapping(uint256 => uint256)) public usedTickets;

    // Refund  tracking
    mapping(address => mapping(uint256 => uint256)) public refundClaims;

    bool public initialized;

    event TicketTierCreated(uint256 indexed tierId, uint256 maxSupply, uint256 price0);
    event TicketPurchased(address indexed buyer, uint256 indexed tierId, uint256 amount, address token);
    event TicketCheckedIn(address indexed user, uint256 tierId);
    event EventStateChanged(EventStatus oldState, EventStatus newState);
    event RefundProcessed(address indexed user, uint256 indexed tierId, uint256 indexed amount);

    error AlreadyInitialized();
    error NotInSetupState();
    error InvalidState();
    error TierExists();
    error TierNotFound();
    error SoldOut();
    error EventPassed();
    error InsufficientPayment();
    error NoUnusedTickets();
    error TokenNotAccepted();
    error RefundNotAvailable();

    modifier onlyOrganizer() {
        require(hasRole(ORGANIZER_ROLE, msg.sender), "Not organizer");
        _;
    }

    modifier inState(EventStatus _state) {
        if (state != _state) revert InvalidState();
        _;
    }

    EventStatus public state;

    constructor() ERC1155("") {}

    /**
    * @notice Initialize cloned contract
    * @dev Called by EventFactory after clone deployment
    */
    function initialize(
        address _organizer,
        uint256 _eventId,
        uint256 _eventDate,
        string calldata _eventName,
        string calldata baseURI
    ) external {
        if (initialized) revert AlreadyInitialized();
        initialized = true;

        factory = msg.sender;
        organizer = _organizer;
        eventId = _eventId;
        eventDate = _eventDate;
        eventName = _eventName;
        state = EventStatus.Setup;

        _setURI(baseURI);

        _grantRole(DEFAULT_ADMIN_ROLE, _organizer);
        _grantRole(ORGANIZER_ROLE, _organizer);

        // Accept native toke by default
        acceptedTokens[address(0)] = true;
    }

    /**
    * @notice Create a new ticket tier
    * @param tierId Unique identifier for tier (0=Regular, 1=VIP, 2=WIP)
    * @param maxSupply Maximum tickets for this tier
    * @param price Price per ticket (in wei or token units)
     */
     function createTier(
        uint256 tierId,
        uint256 maxSupply, 
        uint256 price 
     ) external onlyOrganizer inState(EventStatus.Setup) {
        if (tiers[tierId].exists) revert TierExists();

        tiers[tierId] = TicketTier({
            maxSupply: maxSupply,
            minted: 0,
            price: price,
            exists: true
        });

        emit TicketTierCreated(tierId, maxSupply, price);
     }

     /**
     * @notice TicketTierCreated multiple tiers (gas optimization)
    */
    function createTiersBatch(
        uint256[] calldata tierIds,
        uint256[] calldata maxSupplies,
        uint256[] calldata prices
    )   external
         nonReentrant
         onlyOrganizer
         inState(EventStatus.Setup)
    {
        uint256 length = tierIds.length;
        require(length == maxSupplies.length && length == prices.length, "Length mismatch");

        for (uint256 i = 0; i < length; i++) {
            if (tiers[tierIds[i]].exists) revert TierExists();
        
        tiers[tierIds[i]] = TicketTier({
            maxSupply: maxSupplies[i],
            minted: 0,
            price: prices[i],
            exists: true
            });

            emit TicketTierCreated(tierIds[i], maxSupplies[i], prices[i]);
        }
    }

    /**
     * @notice Activate ticket sales
     */
     function goLive() external onlyOrganizer inState(EventStatus.Setup) {
        EventStatus oldState = state;
        state = EventStatus.Live;
        emit EventStateChanged(oldState, state);
     }

     /**
     * @notice Purchase tickets with native token
    */
    function purchaseTicket(uint256 tierId, uint256 amount) 
        external
        payable
        nonReentrant
        inState(EventStatus.Live)
        whenNotPaused
     {
         _purchaseTicket(tierId, amount, address(0), msg.value);
     }

    /**
      * @notice Purchase tickets with 
      */
    function purchaseTicketWithToken(
        uint256 tierId,
        uint256 amount,
        address token
    ) external nonReentrant inState(EventStatus.Live) whenNotPaused {
        if (!acceptedTokens[token]) revert TokenNotAccepted();

        uint256 totalCost = tiers[tierId].price * amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), totalCost);

        _purchaseTicket(tierId, amount, token, totalCost);
    }

    /**
    * @dev Internal purchase logic
    */
    function _purchaseTicket(
        uint256 tierId,
        uint256 amount,
        address token,
        uint256 payment
    ) private {
        if (!tiers[tierId].exists) revert TierNotFound();
        if (block.timestamp >= eventDate) revert EventPassed();

        TicketTier storage tier = tiers[tierId];
        
        if (tier.minted + amount > tier.maxSupply) revert SoldOut();

        uint256 totalCost = tier.price * amount;
        if (payment < totalCost) revert InsufficientPayment();

        tier.minted += amount;
        _mint(msg.sender, tierId, amount, "");

        // Return excess payment
        if (payment > totalCost && token == address(0)) {
                    payable(msg.sender).transfer(payment - totalCost);
            }
            emit TicketPurchased(msg.sender, tierId, amount, token);
        }
    

        /**
        * @notice Check in a ticket holder
        * @dev Called by authorized verifier (QR scanners)
        */
        function checkIn(address user, uint256 tierId)
            external
            nonReentrant
            onlyRole(VERIFIER_ROLE)
            inState(EventStatus.Live)
        {
            uint256 balance = balanceOf(user, tierId);
            uint256  used = usedTickets[user][tierId];

            if (balance <= used) revert NoUnusedTickets();

            usedTickets[user][tierId]++;

            emit TicketCheckedIn(user, tierId);
        }

        /**
        * @notice Cancel event and enable refunds
         */
         function cancelEvent() external onlyOrganizer {
            if (state == EventStatus.Cancelled) revert InvalidState();

            EventStatus oldState = state;
            state = EventStatus.Cancelled;

            emit EventStateChanged(oldState, state);
         }

         /**
          * @notice Claim refund for cancelled event
          */
        function claimRefund(uint256 tierId) external nonReentrant inState(EventStatus.Cancelled) {
            uint256 balance = balanceOf(msg.sender, tierId);
            uint256 claimed = refundClaims[msg.sender][tierId];

            if (balance <= claimed) revert RefundNotAvailable();

            uint256 refundAmount = (balance -  claimed) * tiers[tierId].price;
            refundClaims[msg.sender][tierId] = balance;

            // Burn refunded tickets
            _burn(msg.sender, tierId, balance - claimed);

            // Process refund (native token only for simplicity)
            (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
            require(success, "Refund failed");

            emit RefundProcessed(msg.sender, tierId, refundAmount);
        }

        /**
        * @notice Withdraw funds to organizer
         */
         function withdraw() external onlyOrganizer nonReentrant {
            require(state == EventStatus.Ended, "Event not ended");

            uint256 balance = address(this).balance;
            payable(organizer).transfer(balance);
         }

         /** 
         * @notice Accepted payment tokens
          */
          function addPaymentToken(address token) external onlyOrganizer {
             acceptedTokens[token] = true;
          }

          /**
          * @notice Mark event as ended
          */
          function endEvent() external onlyOrganizer inState(EventStatus.Live) {
             EventStatus oldState = state;
             state = EventStatus.Ended;
             emit EventStateChanged(oldState, state);
          }

          /**
          * @notice emergency pause
          */
          function pause() external onlyOrganizer {
            _pause();
          }

          function unpause() external onlyOrganizer {
            _unpause();
          }
}



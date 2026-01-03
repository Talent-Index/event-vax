// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IEventManager {
    function isEventCancelled(uint256 eventId) external view returns (bool);
}

/**
* @title TicketNFT
* @notice ERC1155 implementation for multi-tier event tickets
* @dev Cloned per event via EventFactory
*/
contract TicketNFT is ERC1155, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant ORGANIZER_ROLE = keccak256("ORGANIZER");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER");

    struct TicketTier {
        uint256 maxSupply;
        uint256 minted;
        uint256 price;
        bool exists;
    }

    address public factory;
    address public organizer;
    address public marketplace;
    IEventManager public eventManager;

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

    event TicketTierCreated(uint256 indexed tierId, uint256 maxSupply, uint256 price);
    event TicketPurchased(address indexed buyer, uint256 indexed tierId, uint256 amount, address token);
    event TicketCheckedIn(address indexed user, uint256 tierId);
    event RefundProcessed(address indexed user, uint256 indexed tierId, uint256 indexed amount);

    error AlreadyInitialized();
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
        string calldata baseURI,
        address _marketplace,
        address _eventManager
    ) external {
        if (initialized) revert AlreadyInitialized();
        initialized = true;

        factory = msg.sender;
        organizer = _organizer;
        eventId = _eventId;
        eventDate = _eventDate;
        eventName = _eventName;
        marketplace = _marketplace;
        eventManager = IEventManager(_eventManager);

        _setURI(baseURI);

        _grantRole(DEFAULT_ADMIN_ROLE, _organizer);
        _grantRole(ORGANIZER_ROLE, _organizer);

        // Accept native toke by default
        acceptedTokens[address(0)] = true;
    }

    /**
    * @notice Create a new ticket tier
    * @param tierId Unique identifier for tier (0=Regular, 1=VIP, 2=VVIP)
    * @param maxSupply Maximum tickets for this tier
    * @param price Price per ticket (in wei or token units)
     */
     function createTier(
        uint256 tierId,
        uint256 maxSupply, 
        uint256 price 
     ) external onlyOrganizer {
        if (tiers[tierId].exists) revert TierExists();

        tiers[tierId] = TicketTier({
            maxSupply: maxSupply,
            minted: 0,
            price: price,
            exists: true
        });

        if (marketplace != address(0)) {
            (bool success,) = marketplace.call(
                abi.encodeWithSignature("setOriginalPrice(uint256,uint256)", tierId, price)
            );
            require(success, "Marketplace call failed");
        }

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

            if (marketplace != address(0)) {
                (bool success,) = marketplace.call(
                    abi.encodeWithSignature("setOriginalPrice(uint256,uint256)", tierIds[i], prices[i])
                );
                require(success, "Marketplace call failed");
            }

            emit TicketTierCreated(tierIds[i], maxSupplies[i], prices[i]);
        }
    }

    /**
     * @notice Activate ticket sales
     */
     function goLive() external onlyOrganizer {
        require(address(eventManager) == address(0) || !eventManager.isEventCancelled(eventId), "Event cancelled");
     }

     /**
     * @notice Purchase tickets with native token
    */
    function purchaseTicket(uint256 tierId, uint256 amount) 
        external
        payable
        nonReentrant
        whenNotPaused
     {
         require(address(eventManager) == address(0) || !eventManager.isEventCancelled(eventId), "Event cancelled");
         _purchaseTicket(tierId, amount, address(0), msg.value);
     }

    /**
      * @notice Purchase tickets with 
      */
    function purchaseTicketWithToken(
        uint256 tierId,
        uint256 amount,
        address token
    ) external nonReentrant whenNotPaused {
        require(address(eventManager) == address(0) || !eventManager.isEventCancelled(eventId), "Event cancelled");
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
        {
            require(address(eventManager) == address(0) || !eventManager.isEventCancelled(eventId), "Event cancelled");
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
         }

         /**
          * @notice Claim refund for cancelled event
          */
        function claimRefund(uint256 tierId) external nonReentrant {
            require(address(eventManager) != address(0) && eventManager.isEventCancelled(eventId), "Event not cancelled");
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
          function endEvent() external onlyOrganizer {
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

          function supportsInterface(bytes4 interfaceId)
              public
              view
              override(ERC1155, AccessControl)
              returns (bool)
          {
              return super.supportsInterface(interfaceId);
          }
}



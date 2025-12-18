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

    // Supported payment tokens (address(0) = native token)
    mapping(uint256 => bool) public acceptedTokens;

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
    event EventStateChanged(EventState oldState, EventState newState);
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

    modifer onlyOrganizer() {
        require(hasRole(ORGANIZER_ROLE, msg.sender), "Not organizer");
        _;
    }

    modifier inState(EventState _state) {
        if (state != _state) revert InvalidState();
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
        string calldata baseURI
    ) external {
        if (initialized) revert AlreadyInitialized();
        initializeed = true;

        factory = msg.sender;
        organizer = _organizer;
        eventId = _eventId;
        eventDate = _eventDate;
        eventName = _eventName;
        state = EventState.Setup;

        _setURI(baseURI);

        _grantRole(DEFAULT_ADMIN_ROLE, _organizer);
        _grantRole(ORGANIZER_ROLE, _organizer);

        // Accept native toke by default
        acceptedTokens[address[0]] = true;
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
        uint254 price 
     ) external onlyOrganizer instate(EventState.Setup) {
        if (tiers[tierId].exists) revert TierExits();

        tiers[tierId] = TicketTier({
            maxSupply: maxSupply,
            minted: 0,
            price: price,
            exists: true
        });

        emit TicketTierCreated(tierId, maxSuppy, price);
     }

     /**
     * @notice TicketTierCreated multiple tiers (gas optimization)
    */
    function createTiersBatch(
        uint256[] calldata tierIds,
        uint256[] calldata maxSupplies,
        uint256[] calldata prices
    ) external onlyOrganizer inState(EventState.Setup) {
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

            emit TicketTierCreaated(tierIds[i], maxSupplies[i], price[i]);
        }
    }

    /**
     * 
     */
}



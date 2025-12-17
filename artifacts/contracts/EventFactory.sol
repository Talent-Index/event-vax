//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzepppelin/contracts/security/Pausable.sol";

interface ITicketNFT {
    function initialize(
        address organizer,
        uint256 eventId,
        uint256 eventDate,
        uint256 calldata name,
        string calldata baseURI
    ) external;
}

/**
 * @title EvenFactory
 * @notice Central factory for creating event-specific ticket contracts
 * @dev Uses EIP-1167 minimal proxies for gas-efficient deployment
 */
 
contract EventFactorry is AccessControl, Pausable {
    bytes32 public constant PLATFORM_ADMIN = keccak256("PLATFORM_ADMIN");

    address public immutable ticketImplementation;
    address public treasury;

    uint256 public nextEventId;
    uint256 public platformFeesBps = 250; // 2.5%

    // eventId => ticket Contract address
    mapping(uint256 => address) public eventTicket;

    // organizer => event count (reputation tracking)
    mapping(address => uint256) public organizerEventCount;

    event EventCreated(
        uint256 indexed eventId,
        address indexed organizer,
        address ticketContact,
        uint256 eventDate
    );

    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event PlatformFeeUpdated(uint256 oldFee, uint256 newFee);

    error InvalidImplementation();
    error InvalidTreasury();
    error EventDateInPast();
    error FeeTooHigh();

    constructor(
        address _ticketImplementation,
        address _treasury
    ) {
        if (_ticketImplementation == address(0)) revert InvalidImpleentation();
        if (_treasury == address(0)) revert InvalidTreasury();

        ticketImplementation = _ticketImplementation;
        treasury = _treasury;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PLATFORM_ADMIN, msg.sender);
    }

    /**
    * @notice Creates a new event with dedicated ticket contract
    * @param eventDate Unix timestamp of event start
    * @param eventName of the Name of the event 
    * @param baseURI IPFS base URI for metadata
    * @return eventId Unique identifier for the event
    */
    function createEvent(
        uint256 eventDate,
        string calldata eventName,
        string calldata baseURI
    ) external whenNotPaused returns (uint256 eventId) {
        if (eventDate <= block.timestamp) revert EventDateInPast();

        eventId = ++nextEventId;

        // Deploy minimal proxy clone
        address clone = Clones.clone(ticketImplementation);

        // Initialize the clone
        ITicketNFT(clone).initalize(
            msg.sender,
            eventId,
            eventDate,
            eventName,
            baseURI
        );

        eventTicket[eventId] = clone;
        organizerEventCount[msg.sender]++;

        emit EventCreated(evenId, msg.sender, clone, eventDate);
    }

    /**
    * @notice Batch create multiple events (gas optimization)
    */
    function createEventBatch(
        uint256[] calldata eventDates,
        string[] calldata eventNames,
        string[] calldata baseURIs
    ) external whenNotPaused returns (uint256[] memory eventIds) {
        uint256 length = eventDates.length;
        require(
            length == eventNames.length && length == baseURIs.length,
            "Call data Array length mismatch"
        );

        eventIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            eventsIds[i] = this.createEvent(
                eventDates[i],
                eventNames[i],
                baseURIs[i]
            );
        }

    }

    /**
    * @notice Update treasury address
    */
    function setTreasury(address _treasury) external onlyRole(PLATFORM_ADMIN) {
        if (_treasury == address(0)) revert InvalidTreasury();

        address oldTreasury = treasury;
        treasury = _treasury;

        emit TreasuryUpdated(oldTreasury, _treasury);
    }

/**
* @notice Update platform fee (max 10%)
*/
function setPlatformFee(uint256 _feeBps) external onlyRole(PLATFORM_ADMIN) {
    if (_feeBps > 1000) revert FeeTooHigh(); // Max 10%

    uint256 oldFee = platformFeeBps;
    platformFeeBps = _feeBps;

    emit PlatformFeeUpdated(oldFee, _feeBps);
    }

    /**
    * @notice Emergency pause
     */
     function pause() external onlyRole(PLATFORM_ADMIN) {
        _pause();
     }

     function unpause() external onlyRole(PLATFORM_ADMN) {
        _unpause();
     }
}   


// SPDX-Liciense-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title EventManager
 * @notice Manages event lifecylcle and metadata
 * @dev Central registry for event state and validation
 */
contract EventManager is AccessControl, Pausable {
    bytes32 public constant EVENT_ADMIN = keccak256("EVNT_ADMIN");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER");

    enum EventState {
        Draft, // Initial state
        Active, // Sales live
        Ended, // Event Completed
        Cancelled // Event cancelled
    }

    struct EventDetails {
        uint256 eventId;
        address organizer;
        address ticketContract;
        uint256 startTime;
        uint256 endTime;
        uint256 createdAt;
        EventState state;
        bool exists;
    }

    // eventId => EventDetails
    mapping(uint256 => EventDetails) public events;

    // organizer => eventId[]
    mapping(address => uint256[]) public organizersEvents;

    // Total event count
    uint256 public totalEvents;

    // State transition tracking
    mapping(uint256 => mapping(EventState => uint256)) public stateTransitions;

    event EventRegistered(
        uint256  indexed eventId,
        address indexed organizer,
        address ticketContract,
        uint256 startTime,
        uint256 endTime
    );

    event EventStateChanged(
        uint256 indexed eventId,
        EventState previouseState,
        EventState newState
    );

    event EventMetadataUpdated(
        uint256 indexed eventId,
        uint256 startTime,
        uint256 endTime
    )

    error EventNoutFound();
    error InvalidTransition();
    error Unauthorized();
    error InvalidTimestamp();
    error EventAlreadyExists();


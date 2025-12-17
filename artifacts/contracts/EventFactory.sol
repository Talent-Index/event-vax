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
    
    
}
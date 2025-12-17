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
 
 * */
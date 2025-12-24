// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzappelin/contracts/access/AccessControl.sol";

/**
* @title MetadataRegistry
* @notice Centralized IPFS hash storagee and verification
* @dev Ensures metadata integrity across the platform
*/
contract MetadataRegistry is AccessControl {
    bytes32 public constant METADATA_ADMIN = keccak256("METADATA_ADMIN");

    enum MetadataType {
        Event,
        Ticket,
        POAP,
        Badge
    }

    struct Metadata {
        string ipfsHash;
        bytes contentHash; // SHA256 of content
        uint256 timestamp;
        address updatedBy;
        bool frozen;
    }

    // entityTyoe => entityId => Metadata
    mapping(MetadataType => mapping(uint256 => Metadata)) public _metadata;

    // contentHash => exists (prevent duplicates)
    mapping(bytes32 => bool) public contentHashExists;

    // History trana
}
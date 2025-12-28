// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

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
        bytes32 contentHash; // SHA256 of content
        uint256 timestamp;
        address updatedBy;
        bool frozen;
    }

    // entityType => entityId => Metadata
    mapping(MetadataType => mapping(uint256 => Metadata)) public metadata;

    // contentHash => exists (prevent duplicates)
    mapping(bytes32 => bool) public contentHashExists;

    // History tracking
    mapping(MetadataType => mapping(uint256 => Metadata[])) public metadataHistory;

    event MetadataSet(
        MetadataType indexed entityType,
        uint256 indexed entityId,
        string ipfsHash,
        bytes32 contentHash
    );

    event MetadataUpdated(
        MetadataType indexed entityType,
        uint256 indexed entityId,
        string oldIpfsHash,
        string newIpfsHash
    );

    event MetadataFrozen(MetadataType indexed entityType, uint256 indexed entityId);

    error MetadataAlreadyFrozen();
    error InvalidContentHash();
    error MetadataNotFound();

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(METADATA_ADMIN, msg.sender);
    }

    /**
     * @notice Set metadata for entity
     * @param  entityType Type of entity
     * @param entityId Entity identifier
     * @param ipfsHash IPFS hash (CID)
     * @param contentHash SHA256 of content
     */
    function setMetadata(
        MetadataType entityType,
        uint256 entityId,
        string calldata ipfsHash,
        bytes32 contentHash
    ) external onlyRole(METADATA_ADMIN) {
        Metadata storage meta = metadata[entityType][entityId];

        if (meta.frozen) revert MetadataAlreadyFrozen();
        if (contentHash == bytes32(0)) revert InvalidContentHash();

        // Save to history if Updating
        if (bytes(meta.ipfsHash).length > 0) {
            metadataHistory[entityType][entityId].push(meta);

            emit MetadataUpdated(
                entityType,
                entityId,
                meta.ipfsHash,
                ipfsHash
            );
        }

        // Update metadata
        meta.ipfsHash = ipfsHash;
        meta.contentHash = contentHash;
        meta.timestamp = block.timestamp;
        meta.updatedBy = msg.sender;

        contentHashExists[contentHash] = true;

        emit MetadataSet(entityType, entityId, ipfsHash, contentHash);
    } 

    /**
     * @notice Batch set metadata
     */
    function batchSetMetadata(
        MetadataType[] calldata entityTypes,
        uint256[] calldata entityIds,
        string[] calldata ipfsHashes,
        bytes32[] calldata contentHashes
    ) external onlyRole(METADATA_ADMIN) {
        require(
            entityTypes.length == entityIds.length &&
            entityTypes.length == ipfsHashes.length &&
            entityTypes.length == contentHashes.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < entityTypes.length; i++) {
            Metadata storage meta = metadata[entityTypes[i]][entityIds[i]];

            if (!meta.frozen && contentHashes[i] != bytes32(0)) {
                if (bytes(meta.ipfsHash).length > 0) {
                    metadataHistory[entityTypes[i]][entityIds[i]].push(meta);
                }

                meta.ipfsHash = ipfsHashes[i];
                meta.contentHash = contentHashes[i];
                meta.timestamp = block.timestamp;
                meta.updatedBy = msg.sender;

                contentHashExists[contentHashes[i]] = true;

                emit MetadataSet(
                    entityTypes[i],
                    entityIds[i],
                    ipfsHashes[i],
                    contentHashes[i]
                );
            }
        }
    }

    /**
    * @notice Freeze metadata (make immutable) 
    */
    function freezeMetadata(MetadataType entityType, uint256 entityId)
        external
        onlyRole(METADATA_ADMIN)
    {
        Metadata storage meta = metadata[entityType][entityId];
        
        if (bytes(meta.ipfsHash).length == 0) revert MetadataNotFound();

        meta.frozen = true;

        emit MetadataFrozen(entityType, entityId);
    }

    /**
    * @notice Verify content hash
    */
    function getMetadata(MetadataType entityType, uint256 entityId)
        external 
        view
        returns (Metadata memory)
    {
        return metadata[entityType][entityId];
    }

    /**
     * @notice Get metdata history
     */
    function getMetadataHistory(MetadataType entityType, uint256 entityId)
        external
        view
        returns (Metadata[] memory) 
    {
        return metadataHistory[entityType][entityId];
    }

    /**
     * @notice Check if metadata exists
    */
    function metadataExists(MetadataType entityType, uint256 entityId)
        external 
        view
        returns (bool)
    {
        return bytes(metadata[entityType][entityId].ipfsHash).length > 0;
    }

    /**
     * @notice Check if content hash is unique
    */
    function isContentHashUnique(bytes32 contentHash)
        external
        view
        returns (bool)
    {
        return !contentHashExists[contentHash];
    }
}
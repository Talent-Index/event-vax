// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @title POAP ((Proof of Attendance Protocol) 
* @notice ERC721 NFT for event attendees)
 */
conctract POAP is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER");

    Counters.Counter private _tokenIds;

    // eventId => attendee => claimed 
    mapping(uint256 => mapping(address => bool)) public claimed;

    // tokenId => eventId
    mapping(uint256 => uint256) public tokenEvent;

    // tokenId => metadata hash (encrypted off-chain data)
    mapping(uint256 => bytes32) public metadataHash;

    event POAPAwarded(
        uint256 indexed tokenId,
        uint256 indexed eventId,
        address indexed attendee,
        bytes32 metadataHash
    );

    error AlreadyClaimed();
    error Unauthorized();

    constructor() ERC721("EventVerse POAP", "EVPOAP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
    * @notice Award POAP to attendee after check-in
    * @param eventId Event identifier
    * @param attendee Ticket holder address
    * @param _metadataHash of encrypted off-chain metadata
    */
    function awardPOAP(
        uint256 eventId,
        address attendee,
        bytes32 _metadataHash
    ) external onlyRole(VERIFIER_ROLE) {
        if (claimed[eventId][attendee]) revert AlreadyClaimed();

        claimed[eventId][attendee] = true;

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        tokenEvent[tokenId] = eventId;
        metadataHash[tokenId] = _metadataHash;

        _safeMint(attendee, tokenId);

        emit POAPAwarded(tokenId, eventId, attendee, _metadataHash);
    }

}
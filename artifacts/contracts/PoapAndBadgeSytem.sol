// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @title POAP ((Proof of Attendance Protocol) 
* @notice ERC721 NFT for event attendees)
 */
contract POAP is ERC721, AccessControl {
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

    /**
    * @notice Batch award POAPS (gas optimization)
    */
    function awardPOAPBatch(
        uint256 eventId,
        address[] calldata attendees,
        bytes32[] calldata metadataHashes
    ) external onlyRole(VERIFIER_ROLE) {
        uint256 length = attendees.length;
        require(length == metadataHashes.length, "POAP metadata hash Length mismatch");

        for (uint256 i = 0; i < length; i++) {
            if (claimed[eventId][attendees[i]]) continue;

            claimed[eventId][attendees[i]] = true;

            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();

            tokenEvent[tokenId] = eventId;
            metadataHash[tokenId] = metadataHashes[i];

            _safeMint(attendees[i], tokenId);

            emit POAPAwarded(tokenId, eventId, attendees[i], metadataHashes[i]);
        }
    }

    /**
    * @dev Souldbound - prevent transfers
    */
    function _beforeTokenTransfer(
        address from,
        address to, 
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        require(from == address(0) || to == address(0), "POAP: souldbound");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) 
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

/**
 * @title EventBadge
 * @notice ERC721 NFT for evet Organizers (host credentials)
*/
contract EventBadge is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant BADGE_ISSUER_ROLE = keccak256("BADGE_ISSUER");

    Counters.Counter private _badgeIds;

    struct BadgeMetadata {
        uint256 eventId;
        uint256 issuedAt;
        uint256 attendeeCount;
        bytes32 encryptedData; // Hash of encrypted event metadata
    }

    // eventId => organizer => claimed
    mapping(uint256 => mapping(address => bool)) public badgeIssued;

    // badgeId => metadata
    mapping(uint256 => BadgeMetadata) public badgeMetadata;

    event BadgeAwarded(
        uint256 indexed badgeId,
        uint256 indexed eventId, 
        address indexed organizer,
        uint256 attendeeCount
    );

    error BadgeAlreadyIssued();

    constructor() ERC721("EventVerse Host Badge", "EVbadge") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
    * @notice Award badge to organizer after successful event
    * @param eventId Event identifier
    * @param organizer Event host address
    * @param  attendeeCount Number of attendees (reputation metric)
    * @param encryptedData Hash of encrypted event statistics
    */
    function awardBadge(
        uint256 eventId,
        address organizer,
        uint256 attendeeCount,
        bytes32 encryptedData
    ) external onlyRole(BADGE_ISSUER_ROLE) {
        if (badgeIssued[eventId][organizer]) revert BadgeAlreadyIssued();

        badgeIssued[eventId][organizer] = true;

        _badgeIds.increment();
        uint256 badgeId = _badgeIds.current();

        badgeMetadata[badgeId] = BadgeMetadata({
            eventId: eventId,
            issuedAt: block.timestamp,
            attendeeCount: attendeeCount,
            encryptedData: encryptedData
        });

        _safeMint(organizer, badgeId);

        emit BadgeAwarded(badgeId, eventId, organizer, attendeeCount);
    }

    /**
    * @notice Get organizer reputation score
    * @dev Calculate based on number of badges
     */
     function getOrganizerReputation(address organizer) external view returns (uint256) {
        return balanceOf(organizer);
     }

    /**
    * @dev Optional: Allow transfers for reputation trading
    */
    // function supportsInteface(bytes4 interfaceId) 
    //     public 
    //     view
    //     overide(ERC721, AccessControl)
    //     returns (bool)
    // {
    //     return super.supportsInterface(interfaceId);
    // }
}
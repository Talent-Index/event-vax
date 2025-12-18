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


}
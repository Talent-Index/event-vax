// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/securoty/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
* @title Marketplace
* @notice Secondary market for ticket resale with anti-scalping measures
* @dev Implements escrow-based custody and forced royalties 
*/
contract MarketPlace is ERC1155hOLDER, ReentrancyGuard, Pausable, AccessControl {
    bytes32 public constant PLATFORM_ADMIN = keccak_ADMIN = keccak256("PLATFORM_ADMIN");

    struct Listing {
        address seller;
        address ticketContract;
        uint256 tierId;
        uint256 amount;
        uint256 price;
        uint256 listedAt;
        bool active;
    }

    uint256 public nextListingId;
    mapping(uint256 => Listing) public listings;

    // Anti-scalping: time lock before resale
    uint256 public constant LOCK_PERIOD =1 days;
    
    // Price cap: mx 120% of original price
    uint256 public constant MAX_MARKUP_BPS = 12000; // 120%

    // Platform fee: 2.5%
    uint256 public platformFeeBps = 250;

    // Organizer royalty: 1.5%
    uint256 public royaltyBps = 150;

    address public treasury;

    // ticketContract => tierId => original price
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public resaleCount;
    uint256 public constant MX_RESALES = 3;

    event Listed(
        uint256 indexed listingId,
        address indexed seller,
        address ticketContract,
        uint256 tierId,
        uint256 amount,
        uint256 price
    );

    event Sold(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );

    event ListingCancelled(uint256 indexed listingId);
    event PriceUpdated(uint256 indexed listingId, uint256 oldPrice, uint256 newPrice);

    error ListinNotACTIVE();
    error Unauthorized();
    error LockPeriodActive();
    error PriceExceedsCap();
    error InsufficientPayment();
    error MaxResalesReached();
    error InvalidAmount();
}

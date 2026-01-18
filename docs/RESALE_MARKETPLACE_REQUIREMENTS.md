# 🎫 Resale Marketplace - Feature Requirements & Improvements

## 📋 Overview

The EventVerse Resale Marketplace is designed to create a transparent, fair, and secure secondary market for event tickets using blockchain technology. This document outlines the vision, current state, and required improvements.

---

## 🎯 Core Purpose & Vision

### Problems Being Solved

1. **Ticket Scalping**
   - Traditional tickets get bought by bots and resold at 10x prices on sketchy sites
   - No price controls or consumer protection

2. **Fraud & Counterfeiting**
   - Fake tickets, duplicate tickets, or tickets that don't exist
   - No way to verify authenticity before purchase

3. **Lost Control**
   - Event organizers lose control once tickets are sold
   - No visibility into secondary market activity

4. **Lost Revenue**
   - Organizers don't benefit from secondary market sales
   - Scalpers capture all the profit

### What EventVerse Achieves

✅ **Verified Authenticity**
- Every ticket is an NFT on Avalanche blockchain
- Impossible to counterfeit or duplicate
- Ownership is cryptographically proven

✅ **Fair Pricing**
- Smart contracts enforce price caps (e.g., max 150% of original price)
- Prevents scalpers from charging 1000% markup
- Protects fans from exploitation

✅ **Organizer Royalties**
- Event organizers earn percentage on every resale (e.g., 5-10%)
- Creates ongoing revenue stream
- Incentivizes creating great events

✅ **Transparent History**
- Full ownership history on blockchain
- See every transfer and price paid
- Builds trust in the marketplace

✅ **Instant Settlement**
- Smart contracts handle payment automatically
- No waiting for payment processing
- Funds released immediately upon transfer

✅ **Legitimate Secondary Market**
- People who can't attend can sell safely
- Buyers know they're getting real tickets
- Platform-approved resale vs sketchy third parties

---

## 🔧 How It Works

### Resale Flow

1. **List Ticket**
   - Owner sets resale price
   - Smart contract validates price cap
   - Ticket locked in escrow

2. **Marketplace Listing**
   - Ticket appears in public marketplace
   - Searchable and filterable
   - Shows all relevant details

3. **Buyer Purchases**
   - Pays in AVAX
   - Smart contract validates payment

4. **Automatic Split**
   - Platform fee: 2.5%
   - Organizer royalty: 5-10%
   - Seller receives remainder

5. **NFT Transfer**
   - Ownership transfers on-chain
   - Instant and irreversible
   - Recorded on blockchain

6. **Verification**
   - New owner can use ticket at event
   - QR code updates automatically
   - Entry verification system recognizes new owner

---

## ❌ Current UI Limitations

### What's Missing

#### 1. No Marketplace Listings
- Only shows "List for Resale" button
- No way to browse available tickets for sale
- No price discovery mechanism
- No comparison shopping

#### 2. No Buyer Experience
- "Buy Resale Ticket" button exists but doesn't show actual listings
- No search functionality
- No filter by event, price, or date
- No sort options

#### 3. Limited Information Display
- Doesn't show resale price vs original price
- No seller reputation/history
- No transaction history visible
- No price trends or analytics

#### 4. Missing Smart Contract Integration
- No visible price cap enforcement
- No royalty split display
- No escrow status indicator
- No blockchain verification link

#### 5. Poor User Flow
- Confusing navigation
- No clear call-to-action
- Missing onboarding for new users
- No help/FAQ section

---

## ✅ Required Features

### For Sellers

#### Listing Management
- **Price Input**
  - Suggested price range based on demand
  - Real-time price cap validation
  - Warning if price too high/low
  
- **Fee Breakdown**
  - Platform fee (2.5%)
  - Organizer royalty (5-10%)
  - Net proceeds calculation
  - Gas fee estimate

- **Listing Status**
  - Active (visible in marketplace)
  - Pending (awaiting blockchain confirmation)
  - Sold (transaction complete)
  - Cancelled (removed from marketplace)

- **Management Actions**
  - Edit price (before sale)
  - Cancel listing (remove from marketplace)
  - View listing analytics (views, favorites)
  - Relist after cancellation

#### Seller Dashboard
```
My Listings
├── Active (3)
│   ├── Event Name | Price | Views | Actions
│   └── [Edit] [Cancel] [Analytics]
├── Sold (12)
│   └── Event Name | Sold Price | Date | Buyer
└── Cancelled (1)
    └── Event Name | Original Price | Reason
```

---

### For Buyers

#### Marketplace Browse
- **Search Bar**
  - Search by event name
  - Search by venue
  - Search by date range
  - Auto-complete suggestions

- **Filters**
  - Event type (concert, sports, conference)
  - Price range (slider)
  - Date range (calendar picker)
  - Ticket tier (Regular, VIP, VVIP)
  - Location/venue
  - Seller rating

- **Sort Options**
  - Price: Low to High
  - Price: High to Low
  - Date: Soonest First
  - Date: Latest First
  - Recently Listed
  - Most Popular

#### Ticket Cards
```
┌─────────────────────────────┐
│ [Event Image]               │
│                             │
│ Event Name                  │
│ 📅 Date & Time              │
│ 📍 Venue                    │
│                             │
│ 💰 0.5 AVAX                 │
│ Original: 0.3 AVAX (+67%)   │
│                             │
│ 👤 Seller: 0x5f5E...5b99    │
│ ⭐ 4.8 (24 sales)           │
│                             │
│ [Buy Now] [View Details]    │
└─────────────────────────────┘
```

#### Purchase Flow
1. Click "Buy Now"
2. Review purchase details
3. See fee breakdown
4. Connect wallet (if not connected)
5. Confirm transaction in MetaMask
6. Wait for blockchain confirmation
7. Receive ticket NFT
8. View in "My Tickets"

---

### For Trust & Transparency

#### Seller Verification
- ✅ Verified wallet badge
- Number of successful sales
- Average rating (1-5 stars)
- Member since date
- Response time

#### Transaction Details
- **Original Ticket Price**: 0.3 AVAX
- **Current Asking Price**: 0.5 AVAX
- **Price Increase**: +67% (within 150% cap)
- **Platform Fee**: 0.0125 AVAX (2.5%)
- **Organizer Royalty**: 0.025 AVAX (5%)
- **Seller Receives**: 0.4625 AVAX
- **Total Cost**: 0.5 AVAX + gas

#### Blockchain Verification
- Transaction hash link
- Smart contract address
- Block number
- Timestamp
- View on Snowtrace button

#### Price History
```
Price Trend (Last 30 Days)
┌─────────────────────────┐
│     •                   │
│    •  •                 │
│   •    •                │
│  •      •               │
│ •        •              │
└─────────────────────────┘
  Week 1  Week 2  Week 3
```

---

## 🎨 Recommended UI Structure

### Page Layout

```
/resell (Resale Marketplace)
│
├── Header
│   ├── Search Bar
│   ├── Wallet Connection
│   └── Navigation Tabs
│       ├── Browse Listings (default)
│       └── My Listings
│
├── Browse Listings Tab
│   ├── Filters Sidebar (left)
│   │   ├── Event Type
│   │   ├── Price Range
│   │   ├── Date Range
│   │   ├── Ticket Tier
│   │   └── Location
│   │
│   ├── Sort Dropdown (top right)
│   │
│   └── Ticket Grid (main area)
│       ├── Ticket Card 1
│       ├── Ticket Card 2
│       ├── Ticket Card 3
│       └── ... (pagination)
│
└── My Listings Tab
    ├── Active Listings
    │   ├── Listing 1 [Edit] [Cancel]
    │   └── Listing 2 [Edit] [Cancel]
    │
    ├── Sold History
    │   └── Past sales with details
    │
    └── [+ List New Ticket] Button
```

### Mobile Responsive
- Collapsible filters (hamburger menu)
- Stack ticket cards vertically
- Bottom navigation bar
- Swipeable tabs

---

## 🔐 Smart Contract Integration

### Marketplace Contract Functions

```solidity
// List ticket for resale
function listTicket(
    uint256 tokenId,
    uint256 price,
    uint256 eventId
) external

// Buy listed ticket
function buyTicket(
    uint256 listingId
) external payable

// Cancel listing
function cancelListing(
    uint256 listingId
) external

// Update listing price
function updatePrice(
    uint256 listingId,
    uint256 newPrice
) external

// Get active listings
function getActiveListings() 
    external view returns (Listing[] memory)

// Get user listings
function getUserListings(address user) 
    external view returns (Listing[] memory)
```

### Price Cap Enforcement

```solidity
// Maximum resale price (150% of original)
uint256 public constant MAX_RESALE_MULTIPLIER = 150;

function listTicket(...) external {
    uint256 originalPrice = getOriginalPrice(tokenId);
    uint256 maxPrice = (originalPrice * MAX_RESALE_MULTIPLIER) / 100;
    
    require(price <= maxPrice, "Price exceeds cap");
    // ... rest of logic
}
```

### Royalty Distribution

```solidity
function buyTicket(uint256 listingId) external payable {
    Listing memory listing = listings[listingId];
    
    // Calculate fees
    uint256 platformFee = (msg.value * 250) / 10000; // 2.5%
    uint256 royalty = (msg.value * 500) / 10000;     // 5%
    uint256 sellerAmount = msg.value - platformFee - royalty;
    
    // Transfer funds
    platformWallet.transfer(platformFee);
    organizer.transfer(royalty);
    seller.transfer(sellerAmount);
    
    // Transfer NFT
    ticketNFT.safeTransferFrom(seller, buyer, tokenId);
}
```

---

## 📊 Analytics & Insights

### For Sellers
- Total views on listing
- Number of favorites
- Price comparison with similar tickets
- Optimal pricing suggestions
- Time to sell estimate

### For Buyers
- Price trend charts
- Average resale price for event
- Best time to buy recommendations
- Similar tickets comparison
- Deal alerts (price drops)

### For Organizers
- Total resale volume
- Royalty earnings
- Most resold events
- Price trends by tier
- Secondary market health

---

## 🚀 Implementation Priority

### Phase 1: Core Marketplace (MVP)
1. ✅ Browse listings page
2. ✅ Basic search and filters
3. ✅ Ticket card display
4. ✅ Buy now functionality
5. ✅ List ticket form
6. ✅ Smart contract integration

### Phase 2: Enhanced Features
1. Advanced filters and sort
2. Seller profiles and ratings
3. Price history charts
4. Favorites/watchlist
5. Email notifications
6. Mobile app

### Phase 3: Advanced Features
1. Auction-style listings
2. Bundle deals (multiple tickets)
3. Ticket swaps/trades
4. Social features (share, comment)
5. AI price recommendations
6. Fraud detection system

---

## 🎯 Success Metrics

### User Engagement
- Number of listings created
- Number of successful sales
- Average time to sell
- Repeat sellers/buyers
- User retention rate

### Financial
- Total transaction volume
- Platform fee revenue
- Organizer royalty revenue
- Average ticket price
- Price cap compliance rate

### Trust & Safety
- Fraud reports (target: <0.1%)
- Dispute resolution time
- User satisfaction score
- Seller rating average
- Buyer protection claims

---

## 🔮 Future Enhancements

### AI-Powered Features
- Dynamic pricing recommendations
- Demand prediction
- Fraud detection
- Personalized recommendations
- Chatbot support

### Social Features
- Seller profiles with bio
- Buyer/seller messaging
- Review system
- Social sharing
- Referral program

### Advanced Trading
- Ticket options (reserve right to buy)
- Ticket insurance
- Group buying
- Ticket splitting
- Subscription passes

---

## 📝 Notes

- All prices in AVAX (Avalanche native token)
- Gas fees paid by transaction initiator
- Smart contracts deployed on Avalanche C-Chain
- IPFS for ticket metadata storage
- Snowtrace for blockchain verification

---

## 🔗 Related Documents

- [BLOCKCHAIN_INTEGRATION_COMPLETE.md](./BLOCKCHAIN_INTEGRATION_COMPLETE.md)
- [DEPLOYMENT.md](./DEPLOYMENT.md)
- Smart Contract Documentation (contracts/README.md)

---

**Last Updated**: January 2025  
**Status**: Planning & Development Phase  
**Priority**: High

# Deployment Guide

## Critical: EventFactory-EventManager Integration

### Deployment Order

1. **Deploy EventManager**
   ```solidity
   EventManager eventManager = new EventManager();
   ```

2. **Deploy TicketNFT Implementation**
   ```solidity
   TicketNFT ticketImpl = new TicketNFT();
   ```

3. **Deploy EventFactory**
   ```solidity
   EventFactory factory = new EventFactory(
       address(ticketImpl),
       treasuryAddress,
       address(eventManager)
   );
   ```

4. **Grant EVENT_ADMIN Role to EventFactory**
   ```solidity
   bytes32 EVENT_ADMIN = keccak256("EVENT_ADMIN");
   eventManager.grantRole(EVENT_ADMIN, address(factory));
   ```

### Why This Matters

Without step 4, EventFactory cannot call `eventManager.registerEvent()`, causing:
- Events created but not registered
- EventManager unaware of events
- Lifecycle management broken
- State transitions impossible

### Verification

After deployment, verify integration:
```solidity
// Create test event
uint256 eventId = factory.createEvent(
    block.timestamp + 1 days,
    "Test Event",
    "ipfs://..."
);

// Verify registration
EventManager.EventDetails memory details = eventManager.getEventDetails(eventId);
assert(details.exists == true);
```

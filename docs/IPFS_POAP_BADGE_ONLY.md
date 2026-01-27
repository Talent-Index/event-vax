# IPFS Implementation - POAPs and Badges Only

## ✅ Implementation Complete

### Storage Strategy:
- **Event Posters**: Database only (base64)
- **POAPs**: IPFS + MetadataRegistry
- **Badges**: IPFS + MetadataRegistry
- **Tickets**: Database only

### Completed Files:

1. ✅ **server/utils/ipfs.js** - IPFS upload utilities
2. ✅ **server/routes/events.js** - Database-only storage (NO IPFS)
3. ✅ **server/routes/metadata.js** - POAP/Badge IPFS uploads
4. ✅ **server/routes/tickets.js** - Database-only storage
5. ✅ **server/server.js** - Metadata route registered
6. ✅ **src/utils/blockchain.js** - MetadataRegistry functions

### Database Schema:

Events table keeps IPFS columns for future use but doesn't populate them:
```sql
CREATE TABLE events (
  ...
  flyer_image TEXT,           -- base64 (USED)
  ipfs_image_hash TEXT,       -- NULL (reserved)
  ipfs_metadata_hash TEXT,    -- NULL (reserved)
  content_hash TEXT,          -- NULL (reserved)
  ...
);
```

### API Endpoints:

#### 1. Create Event (Database Only)
```
POST /api/events
Body: {
  eventName, eventDate, venue,
  flyerImage: "data:image/jpeg;base64,..."  // Stored in DB
}
Response: { success: true, eventId, data }
```

#### 2. Upload POAP/Badge Metadata (IPFS)
```
POST /api/metadata/upload
Body: {
  type: "POAP" | "Badge",
  metadata: { name, description, attributes },
  image: "data:image/jpeg;base64,..."  // Optional
}
Response: {
  success: true,
  ipfsHash: "Qm...",
  ipfsImageHash: "Qm...",
  contentHash: "0x...",
  ipfsUri: "ipfs://Qm..."
}
```

#### 3. Fetch from IPFS
```
GET /api/metadata/:ipfsHash
Response: { success: true, data: {...} }
```

### Frontend Usage:

#### For Events (No IPFS):
```javascript
// src/pages/Myevent.jsx - NO CHANGES NEEDED
// Events already store base64 in database
const eventData = {
  eventName: formData.eventName,
  flyerImage: flyerImageBase64,  // Stays in database
  ...
};

await fetch('http://localhost:8080/api/events', {
  method: 'POST',
  body: JSON.stringify(eventData)
});
```

#### For POAPs (IPFS):
```javascript
// When creating POAP
const poapMetadata = {
  name: "Event Attendance POAP",
  description: "Proof of attendance",
  attributes: [
    { trait_type: "Event", value: eventName },
    { trait_type: "Date", value: eventDate }
  ]
};

// Upload to IPFS
const response = await fetch('http://localhost:8080/api/metadata/upload', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    type: 'POAP',
    metadata: poapMetadata,
    image: poapImageBase64  // Optional
  })
});

const { ipfsHash, contentHash } = await response.json();

// Register in MetadataRegistry
await registerMetadata(
  MetadataType.POAP,  // 2
  poapId,
  ipfsHash,
  contentHash
);
```

#### For Badges (IPFS):
```javascript
// When creating Badge
const badgeMetadata = {
  name: "VIP Badge",
  description: "Exclusive VIP access badge",
  attributes: [
    { trait_type: "Level", value: "VIP" },
    { trait_type: "Event", value: eventName }
  ]
};

// Upload to IPFS
const response = await fetch('http://localhost:8080/api/metadata/upload', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    type: 'Badge',
    metadata: badgeMetadata,
    image: badgeImageBase64
  })
});

const { ipfsHash, contentHash } = await response.json();

// Register in MetadataRegistry
await registerMetadata(
  MetadataType.Badge,  // 3
  badgeId,
  ipfsHash,
  contentHash
);
```

### MetadataRegistry Usage:

```javascript
import { registerMetadata, MetadataType } from '../utils/blockchain';

// Register POAP
await registerMetadata(MetadataType.POAP, poapId, ipfsHash, contentHash);

// Register Badge
await registerMetadata(MetadataType.Badge, badgeId, ipfsHash, contentHash);

// Get registered metadata
const metadata = await getRegisteredMetadata(MetadataType.POAP, poapId);
console.log(metadata.ipfsHash, metadata.contentHash);
```

### Installation:

```bash
cd server
npm install form-data
npm run dev
```

### Testing:

1. **Test Event Creation (Database)**:
```bash
curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{"eventName":"Test Event","eventDate":"2025-12-31","venue":"Test Venue","flyerImage":"data:image/jpeg;base64,..."}'
```

2. **Test POAP Upload (IPFS)**:
```bash
curl -X POST http://localhost:8080/api/metadata/upload \
  -H "Content-Type: application/json" \
  -d '{"type":"POAP","metadata":{"name":"Test POAP","description":"Test"}}'
```

3. **Test Badge Upload (IPFS)**:
```bash
curl -X POST http://localhost:8080/api/metadata/upload \
  -H "Content-Type: application/json" \
  -d '{"type":"Badge","metadata":{"name":"Test Badge","description":"Test"}}'
```

### Summary:

✅ **Events**: Database only (fast, no IPFS costs)
✅ **POAPs**: IPFS + MetadataRegistry (decentralized, verifiable)
✅ **Badges**: IPFS + MetadataRegistry (decentralized, verifiable)
✅ **Tickets**: Database only (fast ticket purchases)

This approach optimizes for:
- Speed (events/tickets don't wait for IPFS)
- Cost (fewer IPFS uploads)
- Decentralization (POAPs/Badges on IPFS)
- Verification (MetadataRegistry for POAPs/Badges)

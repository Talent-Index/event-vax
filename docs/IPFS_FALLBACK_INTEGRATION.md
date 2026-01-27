# IPFS Fallback Integration Guide

## Overview

This guide outlines how to implement IPFS fallback functionality on the backend server. The system will store metadata backups and serve as a fallback when IPFS gateways are unavailable.

## Database Schema

### Metadata Storage Table

```sql
CREATE TABLE metadata_storage (
    id SERIAL PRIMARY KEY,
    ipfs_hash VARCHAR(255) UNIQUE,
    metadata_id VARCHAR(255) UNIQUE,
    metadata JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    access_count INTEGER DEFAULT 0
);

CREATE INDEX idx_ipfs_hash ON metadata_storage(ipfs_hash);
CREATE INDEX idx_metadata_id ON metadata_storage(metadata_id);
```

## API Endpoints

### 1. Store Metadata Backup

**Endpoint:** `POST /api/metadata/backup`

**Description:** Stores IPFS metadata as backup on server

**Request Body:**
```json
{
  "ipfsHash": "QmYourIPFSHash123...",
  "metadata": {
    "name": "Event Ticket - VIP",
    "description": "Official access ticket",
    "image": "ipfs://QmImageHash...",
    "attributes": [...]
  }
}
```

**Implementation:**
```javascript
app.post('/api/metadata/backup', async (req, res) => {
  try {
    const { ipfsHash, metadata } = req.body;
    
    await db.query(
      'INSERT INTO metadata_storage (ipfs_hash, metadata) VALUES ($1, $2) ON CONFLICT (ipfs_hash) DO UPDATE SET metadata = $2, updated_at = CURRENT_TIMESTAMP',
      [ipfsHash, JSON.stringify(metadata)]
    );
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to store backup' });
  }
});
```

### 2. Upload Metadata to Server

**Endpoint:** `POST /api/metadata/upload`

**Description:** Direct metadata upload when IPFS fails

**Request Body:**
```json
{
  "metadata": {
    "name": "Event Ticket - VIP",
    "description": "Official access ticket",
    "attributes": [...]
  }
}
```

**Implementation:**
```javascript
app.post('/api/metadata/upload', async (req, res) => {
  try {
    const { metadata } = req.body;
    const metadataId = `META_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    await db.query(
      'INSERT INTO metadata_storage (metadata_id, metadata) VALUES ($1, $2)',
      [metadataId, JSON.stringify(metadata)]
    );
    
    res.json({ success: true, metadataId });
  } catch (error) {
    res.status(500).json({ error: 'Failed to upload metadata' });
  }
});
```

### 3. Retrieve Metadata

**Endpoint:** `GET /api/metadata/:uri`

**Description:** Retrieves metadata by IPFS hash or server ID

**Implementation:**
```javascript
app.get('/api/metadata/:uri', async (req, res) => {
  try {
    const { uri } = req.params;
    let result;
    
    if (uri.startsWith('ipfs://')) {
      const ipfsHash = uri.replace('ipfs://', '');
      result = await db.query(
        'SELECT metadata FROM metadata_storage WHERE ipfs_hash = $1',
        [ipfsHash]
      );
    } else if (uri.startsWith('server://')) {
      const metadataId = uri.replace('server://', '');
      result = await db.query(
        'SELECT metadata FROM metadata_storage WHERE metadata_id = $1',
        [metadataId]
      );
    } else {
      return res.status(400).json({ error: 'Invalid URI format' });
    }
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Metadata not found' });
    }
    
    // Increment access count
    await db.query(
      'UPDATE metadata_storage SET access_count = access_count + 1 WHERE ipfs_hash = $1 OR metadata_id = $1',
      [uri.replace(/^(ipfs|server):\/\//, '')]
    );
    
    res.json(result.rows[0].metadata);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve metadata' });
  }
});
```

### 4. Batch Metadata Retrieval

**Endpoint:** `POST /api/metadata/batch`

**Description:** Retrieve multiple metadata objects at once

**Request Body:**
```json
{
  "uris": [
    "ipfs://QmHash1...",
    "server://META_123...",
    "ipfs://QmHash2..."
  ]
}
```

**Implementation:**
```javascript
app.post('/api/metadata/batch', async (req, res) => {
  try {
    const { uris } = req.body;
    const results = {};
    
    for (const uri of uris) {
      try {
        let result;
        if (uri.startsWith('ipfs://')) {
          const ipfsHash = uri.replace('ipfs://', '');
          result = await db.query(
            'SELECT metadata FROM metadata_storage WHERE ipfs_hash = $1',
            [ipfsHash]
          );
        } else if (uri.startsWith('server://')) {
          const metadataId = uri.replace('server://', '');
          result = await db.query(
            'SELECT metadata FROM metadata_storage WHERE metadata_id = $1',
            [metadataId]
          );
        }
        
        if (result && result.rows.length > 0) {
          results[uri] = result.rows[0].metadata;
        }
      } catch (error) {
        console.error(`Error fetching ${uri}:`, error);
      }
    }
    
    res.json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ error: 'Batch retrieval failed' });
  }
});
```

## Frontend Integration

### Updated IPFS Utility

The frontend `src/utils/ipfs.js` should be updated to:

```javascript
export const uploadToIPFS = async (metadata) => {
  try {
    // Try IPFS first
    if (PINATA_API_KEY && PINATA_SECRET_KEY) {
      const response = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'pinata_api_key': PINATA_API_KEY,
          'pinata_secret_api_key': PINATA_SECRET_KEY,
        },
        body: JSON.stringify({
          pinataContent: metadata,
          pinataMetadata: { name: `${metadata.name}-metadata.json` },
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const ipfsURI = `ipfs://${data.IpfsHash}`;
        
        // Store backup on server (non-blocking)
        storeMetadataBackup(data.IpfsHash, metadata).catch(console.warn);
        
        return ipfsURI;
      }
    }
  } catch (error) {
    console.warn('IPFS upload failed, using server fallback:', error);
  }

  // Fallback to server storage
  return await uploadToServer(metadata);
};

const storeMetadataBackup = async (ipfsHash, metadata) => {
  try {
    await fetch('http://localhost:8080/api/metadata/backup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ipfsHash, metadata })
    });
  } catch (error) {
    console.warn('Failed to store server backup:', error);
  }
};

const uploadToServer = async (metadata) => {
  const response = await fetch('http://localhost:8080/api/metadata/upload', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ metadata })
  });

  if (!response.ok) throw new Error('Server upload failed');
  
  const data = await response.json();
  return `server://${data.metadataId}`;
};
```

### Metadata Retrieval Function

```javascript
export const fetchMetadata = async (uri) => {
  try {
    // Try IPFS gateway first for ipfs:// URIs
    if (uri.startsWith('ipfs://')) {
      const ipfsHash = uri.replace('ipfs://', '');
      const gatewayResponse = await fetch(`https://gateway.pinata.cloud/ipfs/${ipfsHash}`, {
        timeout: 5000 // 5 second timeout
      });
      
      if (gatewayResponse.ok) {
        return await gatewayResponse.json();
      }
    }
  } catch (error) {
    console.warn('IPFS gateway failed, trying server fallback');
  }

  // Fallback to server
  const serverResponse = await fetch(`http://localhost:8080/api/metadata/${encodeURIComponent(uri)}`);
  
  if (!serverResponse.ok) {
    throw new Error('Failed to fetch metadata from both IPFS and server');
  }
  
  return await serverResponse.json();
};
```

## Environment Variables

Add to your `.env` file:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/eventvax

# IPFS Backup Settings
ENABLE_IPFS_BACKUP=true
METADATA_CLEANUP_DAYS=30
```

## Cleanup Job (Optional)

```javascript
// Clean up old unused metadata (run daily)
const cleanupOldMetadata = async () => {
  const daysOld = process.env.METADATA_CLEANUP_DAYS || 30;
  
  await db.query(
    'DELETE FROM metadata_storage WHERE created_at < NOW() - INTERVAL $1 DAY AND access_count = 0',
    [daysOld]
  );
};

// Schedule cleanup job
setInterval(cleanupOldMetadata, 24 * 60 * 60 * 1000); // Daily
```

## Testing

### Test IPFS Fallback

```bash
# Test backup storage
curl -X POST http://localhost:8080/api/metadata/backup \
  -H "Content-Type: application/json" \
  -d '{"ipfsHash":"QmTest123","metadata":{"name":"Test Ticket"}}'

# Test direct upload
curl -X POST http://localhost:8080/api/metadata/upload \
  -H "Content-Type: application/json" \
  -d '{"metadata":{"name":"Test Ticket","description":"Test"}}'

# Test retrieval
curl http://localhost:8080/api/metadata/ipfs://QmTest123
curl http://localhost:8080/api/metadata/server://META_123
```

## Implementation Priority

1. **Database setup** - Create metadata_storage table
2. **Basic endpoints** - Implement backup and upload endpoints
3. **Retrieval endpoint** - Handle both IPFS and server URIs
4. **Frontend integration** - Update ipfs.js utility
5. **Testing** - Verify fallback functionality
6. **Optimization** - Add batch retrieval and cleanup jobs

This implementation ensures ticket metadata is always accessible, even when IPFS gateways are down, providing a robust and reliable user experience.
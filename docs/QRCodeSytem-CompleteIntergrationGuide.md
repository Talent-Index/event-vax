# QR Code Verification System - Complete Guide

## Architecture Overview

### Why This Design?

**QR Code Generation**: OFF-CHAIN (Frontend)
- Cheaper (no gas costs)
- Faster (instant)
- Privacy-preserving (data not stored on-chain)
- Flexible (can update format without contract changes)

**QR Code Verification**: ON-CHAIN (Smart Contract)
- Trustless validation
- Tamper-proof check-in records
- Prevents double check-ins
- Automatic POAP distribution

---

## System Components

### 1. Smart Contract (QRVerificationSystem.sol)
- Verifies EIP-712 signatures
- Validates ticket ownership
- Executes check-in
- Awards POAPs
- Prevents replay attacks

### 2. Frontend (Ticket Holder App)
- Generates QR codes with signed data
- Displays QR for scanning
- Shows ticket status

### 3. Scanner App (Verifier)
- Scans QR codes
- Submits to smart contract
- Displays check-in confirmation

---

## Frontend: QR Code Generation

### Step 1: Install Dependencies

```bash
npm install ethers qrcode.react
```

### Step 2: QR Generation Component

```javascript
import { ethers } from 'ethers';
import QRCode from 'qrcode.react';
import { useState, useEffect } from 'react';

const QRVerificationSystem_ABI = [...]; // Import ABI

function TicketQRCode({ eventId, tierId, ticketContract }) {
  const [qrData, setQrData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    generateQRCode();
  }, []);

  async function generateQRCode() {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const attendee = await signer.getAddress();

      // Get contract instance
      const verificationContract = new ethers.Contract(
        QR_VERIFICATION_CONTRACT_ADDRESS,
        QRVerificationSystem_ABI,
        signer
      );

      // Get current nonce
      const nonce = await verificationContract.getCurrentNonce(attendee);
      const nextNonce = nonce.add(1);

      // Set expiration (valid for 24 hours)
      const timestamp = Math.floor(Date.now() / 1000);
      const deadline = timestamp + 86400; // 24 hours

      // Create EIP-712 signature
      const domain = {
        name: 'QRVerificationSystem',
        version: '1',
        chainId: 43114, // Avalanche C-Chain
        verifyingContract: QR_VERIFICATION_CONTRACT_ADDRESS
      };

      const types = {
        QRVerify: [
          { name: 'eventId', type: 'uint256' },
          { name: 'attendee', type: 'address' },
          { name: 'tierId', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'timestamp', type: 'uint256' },
          { name: 'deadline', type: 'uint256' }
        ]
      };

      const value = {
        eventId: eventId,
        attendee: attendee,
        tierId: tierId,
        nonce: nextNonce.toString(),
        timestamp: timestamp,
        deadline: deadline
      };

      // Sign the data
      const signature = await signer._signTypedData(domain, types, value);

      // Create QR data object
      const qrDataObject = {
        version: '1',
        eventId: eventId,
        attendee: attendee,
        tierId: tierId,
        nonce: nextNonce.toString(),
        timestamp: timestamp,
        deadline: deadline,
        signature: signature,
        contractAddress: QR_VERIFICATION_CONTRACT_ADDRESS
      };

      setQrData(JSON.stringify(qrDataObject));
      setLoading(false);
    } catch (error) {
      console.error('QR generation failed:', error);
    }
  }

  if (loading) return <div>Generating QR code...</div>;

  return (
    <div className="qr-container">
      <QRCode 
        value={qrData} 
        size={300}
        level="H" // High error correction
        includeMargin={true}
      />
      <p className="qr-warning">
        ⚠️ Do not share this QR code. Valid for 24 hours.
      </p>
    </div>
  );
}

export default TicketQRCode;
```

### Step 3: Ticket Display with QR

```javascript
function TicketCard({ ticket }) {
  const [showQR, setShowQR] = useState(false);
  const [checkInStatus, setCheckInStatus] = useState(null);

  useEffect(() => {
    checkStatus();
  }, []);

  async function checkStatus() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      QR_VERIFICATION_CONTRACT_ADDRESS,
      QRVerificationSystem_ABI,
      provider
    );

    const status = await contract.getCheckInStatus(
      ticket.eventId,
      await provider.getSigner().getAddress()
    );

    setCheckInStatus(status);
  }

  return (
    <div className="ticket-card">
      <h3>{ticket.eventName}</h3>
      <p>Tier: {ticket.tierName}</p>
      <p>Date: {ticket.eventDate}</p>

      {checkInStatus?.checkedIn ? (
        <div className="checked-in">
          ✅ Checked In
          {checkInStatus.poapAwarded && <p>🏆 POAP Awarded</p>}
        </div>
      ) : (
        <button onClick={() => setShowQR(!showQR)}>
          {showQR ? 'Hide QR Code' : 'Show QR Code'}
        </button>
      )}

      {showQR && !checkInStatus?.checkedIn && (
        <TicketQRCode 
          eventId={ticket.eventId}
          tierId={ticket.tierId}
          ticketContract={ticket.contractAddress}
        />
      )}
    </div>
  );
}
```

---

## Scanner App: QR Code Reading

### Step 1: Scanner Component

```javascript
import { Html5QrcodeScanner } from 'html5-qrcode';
import { ethers } from 'ethers';
import { useState, useEffect } from 'react';

function QRScanner() {
  const [scanner, setScanner] = useState(null);
  const [verifying, setVerifying] = useState(false);
  const [result, setResult] = useState(null);

  useEffect(() => {
    const qrScanner = new Html5QrcodeScanner(
      "qr-reader",
      { fps: 10, qrbox: 250 },
      false
    );

    qrScanner.render(onScanSuccess, onScanError);
    setScanner(qrScanner);

    return () => {
      qrScanner.clear();
    };
  }, []);

  async function onScanSuccess(decodedText) {
    scanner.pause();
    setVerifying(true);

    try {
      // Parse QR data
      const qrData = JSON.parse(decodedText);

      // Validate QR format
      if (qrData.version !== '1') {
        throw new Error('Unsupported QR version');
      }

      // Connect to contract
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      
      const contract = new ethers.Contract(
        qrData.contractAddress,
        QRVerificationSystem_ABI,
        signer
      );

      // Preview verification (optional)
      const [valid, reason] = await contract.verifyQRSignature(
        qrData.eventId,
        qrData.attendee,
        qrData.tierId,
        qrData.nonce,
        qrData.timestamp,
        qrData.deadline,
        qrData.signature
      );

      if (!valid) {
        throw new Error(`Verification failed: ${reason}`);
      }

      // Execute check-in
      const tx = await contract.verifyAndCheckIn(
        qrData.eventId,
        qrData.attendee,
        qrData.tierId,
        qrData.nonce,
        qrData.timestamp,
        qrData.deadline,
        qrData.signature
      );

      setResult({
        status: 'pending',
        message: 'Processing check-in...',
        txHash: tx.hash
      });

      // Wait for confirmation
      const receipt = await tx.wait();

      setResult({
        status: 'success',
        message: '✅ Check-in successful!',
        attendee: qrData.attendee,
        eventId: qrData.eventId,
        txHash: receipt.transactionHash
      });

      // Resume scanning after 3 seconds
      setTimeout(() => {
        scanner.resume();
        setVerifying(false);
        setResult(null);
      }, 3000);

    } catch (error) {
      setResult({
        status: 'error',
        message: error.message
      });

      setTimeout(() => {
        scanner.resume();
        setVerifying(false);
        setResult(null);
      }, 3000);
    }
  }

  function onScanError(error) {
    // Ignore scanning errors (too noisy)
    console.debug('Scan error:', error);
  }

  return (
    <div className="scanner-container">
      <h2>Event Check-In Scanner</h2>
      
      <div id="qr-reader"></div>

      {verifying && (
        <div className="verification-status">
          <p>Verifying ticket...</p>
        </div>
      )}

      {result && (
        <div className={`result result-${result.status}`}>
          <p>{result.message}</p>
          {result.attendee && (
            <p className="attendee">
              Attendee: {result.attendee.slice(0, 6)}...{result.attendee.slice(-4)}
            </p>
          )}
        </div>
      )}
    </div>
  );
}

export default QRScanner;
```

---

## Backend: Event Configuration

### Configure Check-In for Event

```javascript
async function configureEventCheckIn(eventId, eventStartTime, eventEndTime) {
  const provider = new ethers.providers.JsonRpcProvider(AVALANCHE_RPC);
  const wallet = new ethers.Wallet(ADMIN_PRIVATE_KEY, provider);
  
  const contract = new ethers.Contract(
    QR_VERIFICATION_CONTRACT_ADDRESS,
    QRVerificationSystem_ABI,
    wallet
  );

  // Check-in opens 1 hour before event
  const checkInStartTime = eventStartTime - 3600;
  const checkInEndTime = eventEndTime;

  const tx = await contract.configureEventCheckIn(
    eventId,
    TICKET_CONTRACT_ADDRESS,
    POAP_CONTRACT_ADDRESS,
    checkInStartTime,
    checkInEndTime
  );

  await tx.wait();
  console.log(`Check-in configured for event ${eventId}`);
}
```

---

## Security Features

### 1. **Replay Attack Prevention**
```solidity
// Three-layer protection:
- Nonce tracking (incremental per user)
- QR hash uniqueness check
- Signature deadline
```

### 2. **Rate Limiting**
```solidity
// Prevents rapid-fire fake check-ins
uint256 public constant RATE_LIMIT = 10 seconds;
```

### 3. **Time Windows**
```solidity
// Check-in only during valid periods
if (block.timestamp < checkIn.startTime) revert EventNotStarted();
if (block.timestamp > checkIn.endTime) revert EventEnded();
```

### 4. **Self-Signed QR Codes**
```solidity
// Only ticket holder can sign their own QR
if (signer != attendee) revert InvalidSignature();
```

---

## Attack Scenarios & Mitigations

### Attack 1: Screenshot Sharing
**Risk**: User shares QR screenshot

**Mitigation**:
- Each QR used only once (qrCodeUsed mapping)
- Short expiration (24 hours)
- Nonce increments after use

### Attack 2: Replay Attacks
**Risk**: Same QR used multiple times

**Mitigation**:
- Unique hash per QR
- Nonce validation
- Single-use enforcement

### Attack 3: Fake QR Generation
**Risk**: Attacker creates fake QR

**Mitigation**:
- EIP-712 signature verification
- On-chain ticket ownership check
- Signature must match ticket holder

### Attack 4: Time Manipulation
**Risk**: QR used after event

**Mitigation**:
- Deadline enforcement
- Event time window validation

---

## Mobile App Considerations

### iOS/Android QR Scanner

```javascript
// React Native example
import { RNCamera } from 'react-native-camera';

function MobileQRScanner() {
  async function onBarCodeRead({ data }) {
    // Same verification logic as web
    await verifyAndCheckIn(JSON.parse(data));
  }

  return (
    <RNCamera
      style={styles.camera}
      onBarCodeRead={onBarCodeRead}
      barCodeTypes={[RNCamera.Constants.BarCodeType.qr]}
    />
  );
}
```

---

## Testing Checklist

- [ ] QR generation with valid signature
- [ ] QR expiration after deadline
- [ ] Replay attack prevention
- [ ] Rate limiting enforcement
- [ ] Ticket ownership verification
- [ ] Check-in time window validation
- [ ] POAP auto-distribution
- [ ] Batch check-in functionality
- [ ] Scanner error handling
- [ ] Network failure recovery

---

## Gas Cost Estimates

| Operation | Gas Cost | USD (25 gwei, $20 AVAX) |
|-----------|----------|-------------------------|
| Single Check-In | ~150,000 | $0.075 |
| Batch Check-In (10) | ~800,000 | $0.40 |
| Configure Event | ~100,000 | $0.05 |

---

## Deployment Checklist

1. Deploy QRVerificationSystem contract
2. Grant VERIFIER_ROLE to scanner wallets
3. Grant EVENT_ADMIN to backend
4. Configure check-in for events
5. Test QR generation flow
6. Test scanning flow
7. Monitor check-in transactions
8. Set up error alerts

---

## Monitoring & Analytics

### Key Metrics
- Check-ins per minute
- Failed verification attempts
- Average check-in time
- QR generation rate
- Scanner wallet balances

### Alerts
- High failure rate (>10%)
- Rate limit triggers
- Low scanner wallet balance
- Expired QR usage attempts

---

*This system provides enterprise-grade QR verification with minimal on-chain storage and maximum security.*
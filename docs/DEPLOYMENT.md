# 🚀 Eventverse Deployment Information

## Network Details
- **Network:** Avalanche Fuji Testnet
- **Chain ID:** 43113
- **Block Number:** 49920262
- **Deployment Date:** January 2025

## Deployed Contract Addresses

### Core Contracts

| Contract | Address | Explorer Link |
|----------|---------|---------------|
| **EventFactory** | `0x53687CccF774FDa60fE2bd4720237fbb8e4fd02c` | [View](https://testnet.snowtrace.io/address/0x53687cccf774fda60fe2bd4720237fbb8e4fd02c) |
| **TicketNFT Implementation** | `0x6C114E55D520d5a0CFDbF94E29eE7e3ed437fe64` | [View](https://testnet.snowtrace.io/address/0x6c114e55d520d5a0cfdbf94e29ee7e3ed437fe64) |
| **EventManager** | `0x1651f730a846eD23411180eC71C9eFbFCD05A871` | [View](https://testnet.snowtrace.io/address/0x1651f730a846ed23411180ec71c9efbfcd05a871) |
| **Marketplace** | `0x5316aD9DB181111D7dA7AF4d139d223A1DdAB8E1` | [View](https://testnet.snowtrace.io/address/0x5316ad9db181111d7da7af4d139d223a1ddab8e1) |

### Additional Systems

| Contract | Address | Explorer Link |
|----------|---------|---------------|
| **QRVerificationSystem** | `0xd04E0B0959Ceb4f5Be7e29fc0d072368C1EC0e06` | [View](https://testnet.snowtrace.io/address/0xd04e0b0959ceb4f5be7e29fc0d072368c1ec0e06) |
| **POAP** | `0xF149868fab5D3886e33a9096ae8d08C19A5bcC40` | [View](https://testnet.snowtrace.io/address/0xf149868fab5d3886e33a9096ae8d08c19a5bcc40) |
| **EventBadge** | `0x5AE84f40b668979b31c2E601FdbBBd4c04dE6230` | [View](https://testnet.snowtrace.io/address/0x5ae84f40b668979b31c2e601fdbbbd4c04de6230) |
| **MetadataRegistry** | `0xB8F60EAf784b897F7b7AFDabdc67aC6E69fA953b` | [View](https://testnet.snowtrace.io/address/0xb8f60eaf784b897f7b7afdabdc67ac6e69fa953b) |

## Gas Costs

Total deployment cost: **0.000000000024289622 ETH** (~12.1M gas)

## Frontend Integration

Import contract addresses in your frontend:

```javascript
import { CONTRACTS, NETWORK } from './config/contracts';

// Use EventFactory as main entry point
const eventFactory = new ethers.Contract(
  CONTRACTS.EVENT_FACTORY,
  EventFactoryABI,
  signer
);
```

## Key Features

- ✅ All contracts verified on Snowtrace
- ✅ EIP-1167 minimal proxy pattern for gas efficiency
- ✅ Role-based access control
- ✅ Emergency pause functionality
- ✅ QR code verification system
- ✅ POAP and badge rewards

## Next Steps

1. Update frontend configuration with contract addresses
2. Test event creation flow
3. Verify QR code generation
4. Test marketplace functionality
5. Deploy frontend to production

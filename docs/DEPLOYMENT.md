# Deployment Guide

## Prerequisites

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install dependencies:
```bash
forge install
```

## Configuration

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Edit `.env` and fill in:
   - `PRIVATE_KEY`: Your deployment wallet private key (without 0x)
   - `AVALANCHE_FUJI_RPC_URL`: Avalanche Fuji testnet RPC
   - `AVALANCHE_MAINNET_RPC_URL`: Avalanche mainnet RPC
   - `TREASURY_ADDRESS`: Address to receive platform fees

## Deployment

### Deploy to Avalanche Fuji Testnet

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $AVALANCHE_FUJI_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

### Deploy to Avalanche Mainnet

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $AVALANCHE_MAINNET_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

### Dry Run (Simulation)

Test deployment without broadcasting:
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $AVALANCHE_FUJI_RPC_URL \
  -vvvv
```

## Deployed Contracts

### Avalanche Fuji Testnet (Live)

✅ **Deployed on Block 49920262**

```
TicketNFT Implementation: 0x6C114E55D520d5a0CFDbF94E29eE7e3ed437fe64
EventManager:             0x1651f730a846eD23411180eC71C9eFbFCD05A871
Marketplace:              0x5316aD9DB181111D7dA7AF4d139d223A1DdAB8E1
EventFactory:             0x53687CccF774FDa60fE2bd4720237fbb8e4fd02c
QRVerificationSystem:     0xd04E0B0959Ceb4f5Be7e29fc0d072368C1EC0e06
POAP:                     0xF149868fab5D3886e33a9096ae8d08C19A5bcC40
EventBadge:               0x5AE84f40b668979b31c2E601FdbBBd4c04dE6230
MetadataRegistry:         0xB8F60EAf784b897F7b7AFDabdc67aC6E69fA953b
```

**Deployment Stats:**
- Total Gas Used: 12,144,811 gas
- Total Cost: 0.000000000024289622 ETH
- All contracts verified on Snowtrace ✓

**View on Explorer:** https://testnet.snowtrace.io/

### Contract Descriptions

- **TicketNFT Implementation**: Template for cloning ticket contracts
- **EventManager**: Manages event lifecycle and state
- **Marketplace**: Secondary market for ticket resale
- **EventFactory**: Creates new events and ticket contracts
- **QRVerificationSystem**: Handles ticket verification and check-in
- **POAP**: Proof of Attendance Protocol NFTs
- **EventBadge**: Organizer reputation badges
- **MetadataRegistry**: Centralized metadata storage

## Post-Deployment

1. Save all contract addresses from deployment output
2. Update frontend configuration with contract addresses
3. Grant additional roles if needed:
   - VERIFIER_ROLE for QR scanners
   - PLATFORM_ADMIN for platform administrators
   - METADATA_ADMIN for metadata managers

## Verification

Contracts are automatically verified during deployment if `--verify` flag is used.

Manual verification:
```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain-id <CHAIN_ID> \
  --constructor-args $(cast abi-encode "constructor(address)" "<ARG>")
```

## Network Details

### Avalanche Fuji Testnet
- Chain ID: 43113
- RPC: https://api.avax-test.network/ext/bc/C/rpc
- Explorer: https://testnet.snowtrace.io/
- Faucet: https://faucet.avax.network/

### Avalanche Mainnet
- Chain ID: 43114
- RPC: https://api.avax.network/ext/bc/C/rpc
- Explorer: https://snowtrace.io/

## Security Notes

- Never commit `.env` file
- Keep private keys secure
- Test thoroughly on testnet before mainnet deployment
- Consider using a hardware wallet or multisig for mainnet

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

After deployment, the script will output all contract addresses:

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

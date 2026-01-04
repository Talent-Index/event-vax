## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## 🚀 Deployed Contracts (Avalanche Fuji Testnet)

✅ **Live on Block 49920262**

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

**View on Snowtrace:** https://testnet.snowtrace.io/

**Supported Tokens:**
- AVAX (native token) - Default
- Any ERC20 token (configurable by organizers)

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

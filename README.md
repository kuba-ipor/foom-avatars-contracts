# FOOM Smart Contracts

This repository contains the smart contracts for the FOOM platform's content verification and publishing system.

## Contracts

- `GeniusToken.sol`: ERC20 token contract used for content publishing and verification, created per each Genius
- `FoomGeniusAnswer.sol`: Main contract for managing verified content publishing

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Setup

1. Clone the repository
2. Install dependencies:
```bash
forge install
```

### Build

```bash
forge build
```

### Test

Run tests:
```bash
forge test
```

Run tests with gas reporting:
```bash
forge test --gas-report
```

Run tests with more verbosity:
```bash
forge test -vvv
```

### Deployment

1. Create a `.env` file with your private key:
```bash
echo "PRIVATE_KEY=your_private_key_here" > .env
```

2. Deploy to a network:

Testnet (Sepolia):
```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

Mainnet:
```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url $MAINNET_RPC_URL --broadcast --verify -vvvv
```

### Contract Verification

The deployment script automatically verifies contracts if you use the `--verify` flag. Make sure you have set up your API keys:

```bash
export ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Configuration

The deployment configuration can be modified in `script/Deploy.s.sol`:

- `INITIAL_SUPPLY`: Initial supply of genius tokens (default: 1 billion)
- `INITIAL_PUBLISH_COST`: Initial cost to publish an answer (default: 100 tokens)

## Security

- The contracts use OpenZeppelin's secure implementations
- ReentrancyGuard is implemented to prevent reentrancy attacks
- Token burning mechanism is implemented using transfer to address(0)
- Access control is implemented using Ownable

## License

MIT

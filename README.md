# Nyota stablecoin - nTZS
## Abstract
nTZS stands apart as one of the first regulated stablecoin in Africa. As a fully compliant digital asset, nTZS offers unparalleled trust and transparency, ensuring security for all users, institutions, and businesses, unnlocking Africa's Largest Digital Assets Economy. We provide next-generation settlement infrastructure that enables Banks, Payment Service Providers (PSPs), and Mobile Network Operators (MNOs) to offer instant international transfers through their existing customer channels. Your customers use familiar interfaces while you leverage our blockchain-powered settlement network for 80% cost reduction and 99% faster processing.

nTZS, fosters the expansion of fintechs, liquidity providers, and virtual asset entities in Tanzania's digital economy. This initiative is significantly contributing to the growth of Tanzania's digital asset ecosystem.

## Architecture Overview

The nTZS stablecoin implementation follows a modular architecture with the following key components:
<img width="1463" height="683" alt="Screenshot 2025-11-27 at 08 54 44" src="https://github.com/user-attachments/assets/87bc8ec0-589f-498d-9806-effd59a04140" />

### Core Components

1. **NTZS Token Contract**: ERC-20 compliant token with additional features for regulatory compliance, including:
   - Pausable functionality for emergency situations
   - Role-based access control for administrative functions
   - Blacklisting capabilities for compliance requirements
   - Meta-transaction support for gasless transactions

2. **Admin Contract**: Manages role-based access control for the ecosystem:
   - Assigns and revokes roles (Admin, Minter, Blacklister, Pauser)
   - Provides a centralized permission management system
   - Implements multi-step processes for critical role changes

3. **Forwarder Contract**: Enables meta-transactions (gasless transactions):
   - Verifies signatures from users
   - Forwards transactions to the token contract
   - Maintains nonce management to prevent replay attacks

### Meta-Transaction Flow

The nTZS implementation supports gasless transactions through the ERC-2771 meta-transaction pattern:

1. **User Signing**: A user signs a transaction request off-chain with their private key
2. **Relayer Processing**: A relayer (service provider) submits the signed request to the Forwarder contract
3. **Signature Verification**: The Forwarder verifies the signature and nonce
4. **Transaction Execution**: Upon verification, the Forwarder calls the target function on the token contract
5. **Context Recovery**: The token contract recovers the original sender's address using the trusted forwarder pattern

This approach allows users to interact with the nTZS token without needing to hold native tokens (ETH, MATIC, etc.) for gas fees.

### Role Management

The nTZS ecosystem implements a comprehensive role-based access control system:

- **Admin Role**: Can assign other roles and manage system-wide configurations
- **Minter Role**: Authorized to mint new tokens and manage supply
- **Blacklister Role**: Can add or remove addresses from the blacklist
- **Pauser Role**: Can pause and unpause token transfers in emergency situations

Role transitions follow a secure process with appropriate checks and balances to prevent unauthorized access.

## Blockchain
nTZS is currently deployed on the following blockchain protocols:

### Main-Nets

| Network | nTZS Contract Address |
| ------- | ---------------------- |
| BANTU   |  |
| ASSETCHAIN   |  |
| BASE       |            |
| BNBCHAIN   |            |
| ETHEREUM   |            |
| POLYGON    |           |



### Test-Nets

| Network    | nTZS Contract Address                                |
| ---------- | ---------------------------------------------------- |
| BANTU      | GDRIWHLY5XBLY4WMWTVPBPC367NGHDHJAILR7SUMDB3LWMLKWYNI5LTW |
| ASSETCHAIN |            |
| BASE       | 0x19398af7cF46aE7e09261F7Cb6fFC441587E8801           |
| BNBCHAIN   | 0x48811491dA8E32c3F1929202dC7E4F63fF2Bb971           |
| ETHEREUM   |            |
| POLYGON    |            |
| LISK       |            |
| MONAD      |            |
| ARC        |            |

## Developer Guide

### Environment Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/wrappedcbdc/stablecoin-nTZS.git
   cd stablecoin-nTZS
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   - Create a `.env` file in the project root
   - Add the following variables (replace with your values):
   ```
   # Network RPC URLs
   POLYGON_TESTNET=https://rpc-amoy.polygon.technology
   BSC_TESTNET=https://data-seed-prebsc-1-s1.binance.org:8545
   BASE_TESTNET=https://sepolia.base.org
   ASSETCHAIN_TESTNET=https://testnet-rpc.assetchain.com
   ETH_TESTNET=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
   TRON_TESTNET=https://api.shasta.trongrid.io
   
   POLYGON_MAINNET=https://polygon-rpc.com
   ETH_MAINNET=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
   BSC_MAINNET=https://bsc-dataseed.binance.org
   BASE_MAINNET=https://mainnet.base.org
   ASSETCHAIN_MAINNET=https://rpc.assetchain.com
   
   # Private key (without 0x prefix)
   EVM_PRIVATE_KEY=your_private_key_here
   
   # API Keys for verification
   ETH_API_KEY=your_etherscan_api_key
   POLYGON_API_KEY=your_polygonscan_api_key
   BSC_API_KEY=your_bscscan_api_key
   BASE_API_KEY=your_basescan_api_key
   ```

### Running Tests

The project uses Hardhat for testing. To run the test suite:

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test ./test/nTZS.test.js

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Run tests with coverage report
npx hardhat coverage
```

### Test Structure

Tests are organized by contract functionality:

- `nTZS.test.js`: Tests for basic ERC-20 functionality
- `nTZSAdmin.test.js`: Tests for role management and administrative functions
- `nTZSBlacklist.test.js`: Tests for blacklisting functionality
- `nTZSForwarder.test.js`: Tests for meta-transaction functionality
- `nTZSPause.test.js`: Tests for pause/unpause functionality

### Deployment

To deploy contracts to a network:

```bash
# Deploy to testnet
npx hardhat run scripts/deploy.js --network sepolia

# Deploy to mainnet (use with caution)
npx hardhat run scripts/deploy.js --network mainnet
```

### Verification

After deployment, verify contract source code:

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

## Security Considerations

- Never commit your `.env` file or private keys to version control
- Use separate development and production keys
- Follow the principle of least privilege when assigning roles
- Thoroughly test all functionality before mainnet deployment
- Consider professional security audits for production deployments

## License
Software license can be found [here](https://github.com/wrappedcbdc/stablecoin/blob/main/LICENSE)

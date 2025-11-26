## NTZS EVM Contracts

**Built with foundry**


## Usage

### Build

```sh
make build
```

Or:

```sh
forge build
```

### setup .env file at the foundry-scripts folder root
add following fields 
```sh
MAINNET_RPC_URL=
BSC_TESTNET_RPC_URL=
BASE_TESTNET_RPC_URL=
ETHERSCAN_API_KEY=
```

## Run Make Commands

### Create key store

```sh
make keystore
```

### List your keystores to verify

```sh
make wallets
```

### Setup Safe config json file

```sh
make safe-config
```

Edit `safe-config.json` to customize owners and threshold.

### Deploy Safe contracts

```sh
# Using private key (localhost)
make deploy-safe-contracts-local RPC=localhost

# Using rpc url with keystore
make deploy-safe-contracts RPC=<PASS ENV FIELD>
```

### Deploy Safe Wallet

```sh
# Using private key (localhost)
make deploy-gnosis-local RPC=localhost

# Using rpc url with keystore
make deploy-gnosis-wallet RPC=<PASS ENV FIELD>
```

### Clean build artifacts

```sh
make clean
```

### Format code

```sh
make fmt
```

---

## OR use commands below

### Create key store

```sh
# Create encrypted keystore (one-time setup)
cast wallet import deployer --interactive
# Enter your private key when prompted
# Create a strong password
```

### List your keystores to verify

```sh
cast wallet list
```
### Deploy contracts

```sh
# Using private key (localhost)
forge script script/DeployScript.s.sol:DeployScript \
  --rpc-url localhost \
  --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 \
  --broadcast
```

```sh
# Using private key (localhost)
forge script script/TransferOwnershipScript.s.sol:TransferOwnershipScript \
  --rpc-url localhost \
  --private-key 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 \
  --broadcast
```
  
### Setup Safe config json file

```sh
cat > safe-config.json <<'EOF'
{
  "owners": [
    "",
    ""
  ],
  "threshold": 2
}
EOF
```

### Deploy Safe contracts

```sh
# Using private key (localhost)
forge script script/DeploySafeContracts.s.sol:DeploySafeContracts \
  --rpc-url localhost \
  --private-key <PRIVATE KEY> \
  --broadcast

# Or using account from keystore
forge script script/DeploySafeContracts.s.sol:DeploySafeContracts \
  --rpc-url base_testnet \
  --account deployer \
  --broadcast
```

### Deploy Safe Wallet

```sh
# Using private key (localhost)
forge script script/DeployGnosisWallet.s.sol:DeployGnosisWallet \
  --rpc-url localhost \
  --private-key <PRIVATE KEY> \
  --broadcast

# Or using account from keystore
forge script script/DeployGnosisWallet.s.sol:DeployGnosisWallet \
  --rpc-url base_testnet \
  --account deployer \
  --broadcast
```
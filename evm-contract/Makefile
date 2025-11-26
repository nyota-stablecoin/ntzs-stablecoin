### -----------------------------
### EVM Foundry Project Commands
### -----------------------------
.SHELLFLAGS := -e

RPC ?= localhost

# Build contracts
build:
	forge build

### -----------------------------
### Wallet / Keystore Management
### -----------------------------

# Create encrypted keystore (interactive)
keystore:
	cast wallet import deployer --interactive

# List keystores
wallets:
	cast wallet list


### -----------------------------
### Safe Contract Deployments
### -----------------------------

# Generate safe-config.json
# safe-config.json contains the owners and threshold, modify as needed
safe-config:
	@echo '{\n  "owners": [\n    "",\n    ""\n  ],\n  "threshold": 2\n}' > safe-config.json
	@echo "✅ safe-config.json generated"


### -----------------------------
### Contract Deployments
### -----------------------------

deploy:
	forge script script/DeployScript.s.sol:DeployScript \
		--rpc-url $(RPC) \
		--account deployer \
	    --broadcast 

# Upgrade Ntzs contract
upgrade-proxy:
	forge script script/UpgradeProxyScript.s.sol:UpgradeProxyScript \
		--rpc-url ${RPC} \
		--broadcast \
		--account deployer \

# Transfer ownership of contracts and ProxyAdmin
transfer-ownership:
	forge script script/TransferOwnershipScript.s.sol:TransferOwnershipScript \
		--rpc-url ${RPC} \
		--broadcast \
		--account deployer \

# Deploy Safe infra contracts (localhost, using private key)
deploy-safe-contracts-local:
	forge script script/DeploySafeContracts.s.sol:DeploySafeContracts \
		--rpc-url ${RPC} \
		--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
		--broadcast

# Deploy Safe infra contracts (Base testnet, using keystore)

deploy-safe-contracts:
	forge script script/DeploySafeContracts.s.sol:DeploySafeContracts \
		--rpc-url $(RPC) \
		--account deployer \
		--broadcast


### -----------------------------
### Safe Wallet Deployments
### -----------------------------

# Deploy Safe wallet (localhost, using private key)
deploy-gnosis-local:
	forge script script/DeployGnosisSafeWallet.s.sol:DeployGnosisSafeWallet \
		--rpc-url ${RPC} \
		--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
		--broadcast

# Deploy Safe wallet (Base testnet, using keystore)

deploy-gnosis-wallet:
	forge script script/DeployGnosisSafeWallet.s.sol:DeployGnosisSafeWallet \
		--rpc-url $(RPC) \
		--account deployer \
		--broadcast


### ------------------------
### Test
### -----------------------------

test-ntzs:
	forge test --match-contract Ntzs2

test-operations:
	forge test --match-contract Operations2

### Utilities
### -----------------------------

# Remove build artifacts
clean:
	forge clean

# Run formatter
fmt:
	forge fmt

.PHONY: build keystore wallets safe-config deploy-safe-contracts-local deploy-safe-contracts \
deploy-gnosis-local deploy-safe-wallet clean fmt

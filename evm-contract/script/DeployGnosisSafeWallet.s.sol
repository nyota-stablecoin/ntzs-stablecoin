// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@safe-global/safe-contracts/contracts/Safe.sol";
import "@safe-global/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import "@safe-global/safe-contracts/contracts/handler/CompatibilityFallbackHandler.sol";

contract DeployGnosisSafeWallet is Script {
    struct SafeConfig {
        address[] owners;
        uint256 threshold;
    }

    // Load the contract addresses from the JSON file
    function loadContractAddresses()
        internal
        view
        returns (address safeMasterCopy, address proxyFactory, address fallbackHandler)
    {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/safe-contracts.json");
        string memory json = vm.readFile(path);

        safeMasterCopy = vm.parseJsonAddress(json, ".safeMasterCopyAddress");
        proxyFactory = vm.parseJsonAddress(json, ".safeProxyFactoryAddress");
        fallbackHandler = vm.parseJsonAddress(json, ".fallbackHandlerAddress");
    }

    // Load Safe configuration (owners and threshold) from JSON file
    function loadSafeConfig() internal view returns (SafeConfig memory config) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/safe-config.json");
        string memory json = vm.readFile(path);

        // Parse threshold
        config.threshold = vm.parseJsonUint(json, ".threshold");

        // Parse owners array
        bytes memory ownersData = vm.parseJson(json, ".owners");
        config.owners = abi.decode(ownersData, (address[]));
    }

    function run() external {
        // Load deployed contract addresses
        (address safeMasterCopyAddress, address proxyFactoryAddress, address fallbackHandlerAddress) =
            loadContractAddresses();

        console.log("Using Safe Master Copy:", safeMasterCopyAddress);
        console.log("Using Proxy Factory:", proxyFactoryAddress);
        console.log("Using Fallback Handler:", fallbackHandlerAddress);

        // Load Safe configuration
        SafeConfig memory safeConfig = loadSafeConfig();

        console.log("\nSafe Configuration:");
        console.log("Threshold:", safeConfig.threshold);
        console.log("Number of owners:", safeConfig.owners.length);
        for (uint256 i = 0; i < safeConfig.owners.length; i++) {
            console.log("Owner", i + 1, ":", safeConfig.owners[i]);
        }

        vm.startBroadcast();

        // Prepare Safe initialization data
        bytes memory initializer = abi.encodeWithSelector(
            Safe.setup.selector,
            safeConfig.owners, // _owners
            safeConfig.threshold, // _threshold
            address(0), // to (for optional delegate call)
            "", // data (for optional delegate call)
            fallbackHandlerAddress, // fallbackHandler
            address(0), // paymentToken
            0, // payment
            payable(address(0)) // paymentReceiver
        );

        // Deploy Safe proxy
        SafeProxyFactory factory = SafeProxyFactory(proxyFactoryAddress);
        SafeProxy proxy = factory.createProxyWithNonce(
            safeMasterCopyAddress, initializer, uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))
        );

        address newSafeAddress = address(proxy);
        console.log(unicode"\n✅ New Safe address:", newSafeAddress);

        vm.stopBroadcast();

        // Build JSON output with owners array
        string memory ownersJson = "";
        for (uint256 i = 0; i < safeConfig.owners.length; i++) {
            ownersJson = string(
                abi.encodePacked(ownersJson, '    "', vm.toString(safeConfig.owners[i]), '"', i < safeConfig.owners.length - 1 ? ",\n" : "\n")
            );
        }

        string memory json = string(
            abi.encodePacked(
                "{\n",
                '  "safeAddress": "',
                vm.toString(newSafeAddress),
                '",\n',
                '  "owners": [\n',
                ownersJson,
                "  ],\n",
                '  "threshold": ',
                vm.toString(safeConfig.threshold),
                "\n}"
            )
        );

        string memory outputPath = string.concat(vm.projectRoot(), "/deployed-safe-wallet.json");
        vm.writeFile(outputPath, json);
        console.log(unicode"💾 Safe deployment info saved to deployed-safe-wallet.json\n");
    }
}
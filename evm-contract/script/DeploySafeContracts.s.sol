// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@safe-global/safe-contracts/contracts/Safe.sol";
import "@safe-global/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import "@safe-global/safe-contracts/contracts/handler/CompatibilityFallbackHandler.sol";
import "@safe-global/safe-contracts/contracts/libraries/MultiSend.sol";
import "@safe-global/safe-contracts/contracts/libraries/MultiSendCallOnly.sol";
import "@safe-global/safe-contracts/contracts/libraries/SignMessageLib.sol";
import "@safe-global/safe-contracts/contracts/libraries/CreateCall.sol";

contract DeploySafeContracts is Script {
    function run() external {
        // The deployer will be set by --account flag or --private-key flag
        // No need to read from environment variables

        vm.startBroadcast();

        console.log("Deploying contracts with:", msg.sender);

        // Deploy Safe Master Copy
        Safe safeMasterCopy = new Safe();
        console.log(unicode"✅ Safe Master Copy:", address(safeMasterCopy));

        // Deploy Proxy Factory
        SafeProxyFactory proxyFactory = new SafeProxyFactory();
        console.log(unicode"✅ Safe Proxy Factory:", address(proxyFactory));

        // Deploy Fallback Handler
        CompatibilityFallbackHandler fallbackHandler = new CompatibilityFallbackHandler();
        console.log(unicode"✅ Fallback Handler:", address(fallbackHandler));

        // Deploy MultiSend
        MultiSend multiSend = new MultiSend();
        console.log(unicode"✅ MultiSend:", address(multiSend));

        // Deploy MultiSendCallOnly
        MultiSendCallOnly multiSendCallOnly = new MultiSendCallOnly();
        console.log(unicode"✅ MultiSendCallOnly:", address(multiSendCallOnly));

        // Deploy SignMessageLib
        SignMessageLib signMessageLib = new SignMessageLib();
        console.log(unicode"✅ SignMessageLib:", address(signMessageLib));

        // Deploy CreateCall
        CreateCall createCall = new CreateCall();
        console.log(unicode"✅ CreateCall:", address(createCall));

        vm.stopBroadcast();

        // Write addresses to JSON file
        string memory json = string(
            abi.encodePacked(
                "{\n",
                '  "safeMasterCopyAddress": "',
                vm.toString(address(safeMasterCopy)),
                '",\n',
                '  "safeProxyFactoryAddress": "',
                vm.toString(address(proxyFactory)),
                '",\n',
                '  "fallbackHandlerAddress": "',
                vm.toString(address(fallbackHandler)),
                '",\n',
                '  "multiSendAddress": "',
                vm.toString(address(multiSend)),
                '",\n',
                '  "multiSendCallOnlyAddress": "',
                vm.toString(address(multiSendCallOnly)),
                '",\n',
                '  "signMessageLibAddress": "',
                vm.toString(address(signMessageLib)),
                '",\n',
                '  "createCallAddress": "',
                vm.toString(address(createCall)),
                '"\n',
                "}"
            )
        );

        string memory path = string.concat(
            vm.projectRoot(),
            "/safe-contracts.json"
        );
        vm.writeFile(path, json);
        console.log(
            unicode"\n💾 All deployed contract addresses saved to safe-contracts.json\n"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Operations2.sol";
import "../src/Forwarder.sol";
import "../src/Ntzs2.sol";

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployScript is Script {
    function run() external {
        

        vm.startBroadcast();

        // 1️⃣ Deploy ProxyAdmin
        console.log("Deploying ProxyAdmin...");
        ProxyAdmin proxyAdmin = new ProxyAdmin();
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));

        // 2️⃣ Deploy Admin implementation contract
        console.log("Deploying Admin implementation...");
        Admin2 adminImpl = new Admin2();
        console.log("Admin implementation deployed at:", address(adminImpl));

        // 3️⃣ Deploy Admin proxy with initialize call
        console.log("Deploying Admin TransparentUpgradeableProxy...");
        TransparentUpgradeableProxy adminProxy = new TransparentUpgradeableProxy(
            address(adminImpl),
            address(proxyAdmin),
            abi.encodeCall(Admin2.initialize, ())
        );
        console.log("Admin proxy deployed at:", address(adminProxy));

        // 4️⃣ Deploy Forwarder contract (non-upgradeable)
        console.log("Deploying Forwarder...");
        Forwarder forwarder = new Forwarder(address(adminProxy));
        console.log("Forwarder deployed at:", address(forwarder));

        // 5️⃣ Deploy Ntzs implementation contract
        console.log("Deploying Ntzs implementation...");
        Ntzs2 ntzsImpl = new Ntzs2();
        console.log("Ntzs implementation deployed at:", address(ntzsImpl));

        // 6️⃣ Deploy Ntzs proxy with initialize call
        console.log("Deploying Ntzs TransparentUpgradeableProxy...");
        TransparentUpgradeableProxy ntzsProxy = new TransparentUpgradeableProxy(
            address(ntzsImpl),
            address(proxyAdmin),
            abi.encodeCall(Ntzs2.initialize, (address(forwarder), address(adminProxy)))
        );
        console.log("Ntzs proxy deployed at:", address(ntzsProxy));

        vm.stopBroadcast();

        // console.log("\n=== Verification Commands ===");

        // console.log("Admin Implementation:");
        // console.log(
        //     string.concat(
        //         "forge verify-contract ",
        //         vm.toString(address(adminImpl)),
        //         " Admin --chain <chain-id>"
        //     )
        // );

        // console.log("\nForwarder:");
        // console.log(
        //     string.concat(
        //         "forge verify-contract ",
        //         vm.toString(address(forwarder)),
        //         " Forwarder --chain <chain-id> --constructor-args $(cast abi-encode \"constructor(address)\" ",
        //         vm.toString(address(adminProxy)),
        //         ")"
        //     )
        // );

        // console.log("\nNtzs Implementation:");
        // console.log(
        //     string.concat(
        //         "forge verify-contract ",
        //         vm.toString(address(ntzsImpl)),
        //         " Ntzs --chain <chain-id>"
        //     )
        // );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IProxyAdmin {
    function upgrade(address proxy, address implementation) external;
    function owner() external view returns (address);
}

contract UpgradeProxyScript is Script {
    // Proxy address to upgrade
    address constant PROXY_ADDRESS = address(0);

    //New implementation address (deployed separately)
    address constant NEW_IMPL_ADDRESS = address(0);

    //ProxyAdmin address managing the proxy
    address constant PROXY_ADMIN_ADDRESS = address(0);

    function run() external {
        // The deployer will be set by --account flag or --private-key flag
        // No need to read from environment variables

        console.log("Deployer Address:", msg.sender);
        console.log("Proxy Address:", PROXY_ADDRESS);
        console.log("New Implementation Address:", NEW_IMPL_ADDRESS);
        console.log("ProxyAdmin Address:", PROXY_ADMIN_ADDRESS);

        vm.startBroadcast();

        IProxyAdmin proxyAdmin = IProxyAdmin(PROXY_ADMIN_ADDRESS);

        require(proxyAdmin.owner() == msg.sender, "You are not the ProxyAdmin owner");

        // Upgrade the proxy to new implementation
        proxyAdmin.upgrade(PROXY_ADDRESS, NEW_IMPL_ADDRESS);
        console.log(unicode"✓ Proxy upgraded successfully");

        vm.stopBroadcast();

        console.log("\n=== Verify Implementation ===");
        console.log(
            string.concat(
                "forge verify-contract ",
                vm.toString(NEW_IMPL_ADDRESS),
                " Ntzs --chain <chain-id>"
            )
        );
    }
}

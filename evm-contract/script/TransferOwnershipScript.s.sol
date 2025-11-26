// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IProxyAdmin {
    function transferOwnership(address newOwner) external;
    function owner() external view returns (address);
}

interface IOwnable {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

contract TransferOwnershipScript is Script {
    // PROXY ADDRESSES
    address constant ADMIN_PROXY_ADDRESS =
         address(0);
    address constant FORWARDER_ADDRESS =
        address(0);
    address constant NTZS_PROXY_ADDRESS =
         address(0);

    address constant NEW_OWNER_ADDRESS =
        address(0);
    address constant NEW_PROXY_ADMIN_ADDRESS =
       address(0);

    function run() external {
        // The deployer will be set by --account flag or --private-key flag
        // No need to read from environment variables

        console.log("Deployer Address:", msg.sender);
        console.log("New Owner Address:", NEW_OWNER_ADDRESS);
        console.log("New ProxyAdmin Address:", NEW_PROXY_ADMIN_ADDRESS);

        vm.startBroadcast();

        // Transfer ownership of Admin contract
        IOwnable admin = IOwnable(ADMIN_PROXY_ADDRESS);
        require(admin.owner() == msg.sender, "Not owner of Admin contract");
        admin.transferOwnership(NEW_OWNER_ADDRESS);
        address adminNewOwner = admin.owner();
        require(
            adminNewOwner == NEW_OWNER_ADDRESS,
            "Admin ownership transfer failed"
        );
        console.log(unicode"✓ Admin ownership transferred");

        // Transfer ownership of Forwarder contract
        IOwnable forwarder = IOwnable(FORWARDER_ADDRESS);
        require(
            forwarder.owner() == msg.sender,
            "Not owner of Forwarder contract"
        );
        forwarder.transferOwnership(NEW_OWNER_ADDRESS);
        address forwarderNewOwner = forwarder.owner();
        require(
            forwarderNewOwner == NEW_OWNER_ADDRESS,
            "Forwarder ownership transfer failed"
        );
        console.log(unicode"✓ Forwarder ownership transferred");

        // Transfer ownership of Ntzs contract
        IOwnable ntzs = IOwnable(NTZS_PROXY_ADDRESS);
        require(ntzs.owner() == msg.sender, "Not owner of Ntzs contract");
        ntzs.transferOwnership(NEW_OWNER_ADDRESS);
        address ntzsNewOwner = ntzs.owner();
        require(
            ntzsNewOwner == NEW_OWNER_ADDRESS,
            "Ntzs ownership transfer failed"
        );
        console.log(unicode"✓ Ntzs ownership transferred");

        // Transfer ProxyAdmin ownership (usually shared)
        // We assume ProxyAdmin contract is owner of proxies
        // Must call transferOwnership on ProxyAdmin contract manually

        IProxyAdmin proxyAdminAdmin = IProxyAdmin(
            _getProxyAdmin(ADMIN_PROXY_ADDRESS)
        );
        require(proxyAdminAdmin.owner() == msg.sender, "Not ProxyAdmin owner");
        proxyAdminAdmin.transferOwnership(NEW_PROXY_ADMIN_ADDRESS);

        console.log(unicode"✓ ProxyAdmin ownership transferred");
        address proxyAdminNewOwner = proxyAdminAdmin.owner();
        require(
            proxyAdminNewOwner == NEW_PROXY_ADMIN_ADDRESS,
            "ProxyAdmin ownership transfer failed"
        );

        vm.stopBroadcast();

        console.log("Ownership transfer complete!");
    }

    // Helper to get ProxyAdmin from proxy (calls EIP1967 admin slot)
    function _getProxyAdmin(
        address proxy
    ) internal view returns (address adminAddr) {
        bytes32 ADMIN_SLOT = bytes32(
            uint256(keccak256("eip1967.proxy.admin")) - 1
        );
        bytes32 rawAdmin = vm.load(proxy, ADMIN_SLOT);
        adminAddr = address(uint160(uint256(rawAdmin)));
    }
}

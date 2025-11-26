// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/Operations2.sol";

// OZ Transparent Proxy
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract Operations2Test is Test {
    Admin2 public admin;
    ProxyAdmin public proxyAdmin;
    address public owner;
    address public user1;
    address public user2;
    address public trustedContractAddr;
    address public evilUser;

    event AddedBlackList(address indexed _user);
    event RemovedBlackList(address indexed _user);
    event MintAmountAdded(address indexed _user);
    event MintAmountRemoved(address indexed _user);
    event WhitelistedForwarder(address indexed _user);
    event BlackListedForwarder(address indexed _user);
    event WhitelistedMinter(address indexed _user);
    event BlackListedMinter(address indexed _user);
    event WhitelistedContract(address indexed _user);
    event BlackListedContract(address indexed _user);
    event WhitelistedExternalSender(address indexed _user);
    event BlackListedExternalSender(address indexed _user);
    event WhitelistedInternalUser(address indexed _user);
    event BlackListedInternalUser(address indexed _user);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        trustedContractAddr = makeAddr("trustedContract");
        evilUser = makeAddr("evilUser");

        // 1️⃣ Deploy ProxyAdmin
        proxyAdmin = new ProxyAdmin();
        proxyAdmin.transferOwnership(owner);

        // 2️⃣ Deploy implementation contract
        Admin2 impl = new Admin2();

        // 3️⃣ Deploy Transparent Proxy and call initialize()
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            address(proxyAdmin),
            abi.encodeCall(Admin2.initialize, ())
        );

        // 4️⃣ Cast proxy to contract interface
        admin = Admin2(address(proxy));
        //admin.whitelistExternalSender(minter);
    }

    // ============================================
    // TEST 1: Initialization Test
    // ============================================
    function test_01_Initialization_Success() public view {
        // A: Check owner is set correctly
        assertEq(admin.owner(), owner, "Owner should be set correctly");
        
        // B: Check deployer has canForward and canMint permissions
        assertTrue(admin.canForward(owner), "Owner should have canForward permission");
        assertTrue(admin.canMint(owner), "Owner should have canMint permission");
    }

    // ============================================
    // TEST 2: Add/Remove Minter
    // ============================================
    function test_02A_AddCanMint_Success() public {
        // A: Successfully add a minter
        vm.expectEmit(true, false, false, false);
        emit WhitelistedMinter(user1);
        
        bool success = admin.addCanMint(user1);
        
        assertTrue(success, "Should return true");
        assertTrue(admin.canMint(user1), "User1 should be a minter");
    }

    function test_02B_AddCanMint_Failure_AlreadyMinter() public {
        // B: Fail when adding an existing minter
        admin.addCanMint(user1);
        
        vm.expectRevert("User already added as minter");
        admin.addCanMint(user1);
    }

    // ============================================
    // TEST 3: Remove Minter
    // ============================================
    function test_03A_RemoveCanMint_Success() public {
        // A: Successfully remove a minter
        admin.addCanMint(user1);
        admin.addMintAmount(user1, 1000);
        
        vm.expectEmit(true, false, false, false);
        emit BlackListedMinter(user1);
        
        bool success = admin.removeCanMint(user1);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.canMint(user1), "User1 should not be a minter");
        assertEq(admin.mintAmount(user1), 0, "Mint amount should be reset to 0");
    }

    function test_03B_RemoveCanMint_Failure_NotMinter() public {
        // B: Fail when removing non-existent minter
        vm.expectRevert("User is not a minter");
        admin.removeCanMint(user1);
    }

    // ============================================
    // TEST 4: Add/Remove Mint Amount
    // ============================================
    function test_04A_AddMintAmount_Success() public {
        // A: Successfully add mint amount for authorized minter
        admin.addCanMint(user1);
        
        vm.expectEmit(true, false, false, false);
        emit MintAmountAdded(user1);
        
        bool success = admin.addMintAmount(user1, 5000);
        
        assertTrue(success, "Should return true");
        assertEq(admin.mintAmount(user1), 5000, "Mint amount should be 5000");
    }

    function test_04B_AddMintAmount_Failure_NotMinter() public {
        // B: Fail when adding mint amount for non-minter
        vm.expectRevert();
        admin.addMintAmount(user1, 5000);
    }

    // ============================================
    // TEST 5: Forwarder Management
    // ============================================
    function test_05A_AddCanForward_Success() public {
        // A: Successfully add a forwarder
        vm.expectEmit(true, false, false, false);
        emit WhitelistedForwarder(user1);
        
        bool success = admin.addCanForward(user1);
        
        assertTrue(success, "Should return true");
        assertTrue(admin.canForward(user1), "User1 should be a forwarder");
    }

    function test_05B_AddCanForward_Failure_BlacklistedUser() public {
        // B: Fail when adding blacklisted user as forwarder
        admin.addBlackList(user1);
        
        vm.expectRevert("User is blacklisted");
        admin.addCanForward(user1);
    }

    // ============================================
    // TEST 6: Remove Forwarder
    // ============================================
    function test_06A_RemoveCanForward_Success() public {
        // A: Successfully remove a forwarder
        admin.addCanForward(user1);
        
        vm.expectEmit(true, false, false, false);
        emit BlackListedForwarder(user1);
        
        bool success = admin.removeCanForward(user1);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.canForward(user1), "User1 should not be a forwarder");
    }

    function test_06B_RemoveCanForward_Failure_NotForwarder() public {
        // B: Fail when removing non-existent forwarder
        vm.expectRevert("User is not a forwarder");
        admin.removeCanForward(user1);
    }

    // ============================================
    // TEST 7: Trusted Contract Management
    // ============================================
    function test_07A_AddTrustedContract_Success() public {
        // A: Successfully add trusted contract
        vm.expectEmit(true, false, false, false);
        emit WhitelistedContract(trustedContractAddr);
        
        bool success = admin.addTrustedContract(trustedContractAddr);
        
        assertTrue(success, "Should return true");
        assertTrue(admin.trustedContract(trustedContractAddr), "Should be trusted");
    }

    function test_07B_AddTrustedContract_Failure_AlreadyAdded() public {
        // B: Fail when adding existing trusted contract
        admin.addTrustedContract(trustedContractAddr);
        
        vm.expectRevert("Contract already added");
        admin.addTrustedContract(trustedContractAddr);
    }

    // ============================================
    // TEST 8: Remove Trusted Contract
    // ============================================
    function test_08A_RemoveTrustedContract_Success() public {
        // A: Successfully remove trusted contract
        admin.addTrustedContract(trustedContractAddr);
        
        vm.expectEmit(true, false, false, false);
        emit BlackListedContract(trustedContractAddr);
        
        bool success = admin.removeTrustedContract(trustedContractAddr);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.trustedContract(trustedContractAddr), "Should not be trusted");
    }

    function test_08B_RemoveTrustedContract_Failure_NotExists() public {
        // B: Fail when removing non-existent trusted contract
        vm.expectRevert("Contract does not exist");
        admin.removeTrustedContract(trustedContractAddr);
    }

    // ============================================
    // TEST 9: External Sender Whitelist
    // ============================================
    function test_09A_WhitelistExternalSender_Success() public {
        // A: Successfully whitelist external sender
        vm.expectEmit(true, false, false, false);
        emit WhitelistedExternalSender(user1);
        
        bool success = admin.whitelistExternalSender(user1);
        
        assertTrue(success, "Should return true");
        assertTrue(admin.isExternalSenderWhitelisted(user1), "Should be whitelisted");
    }

    function test_09B_WhitelistExternalSender_Failure_AlreadyWhitelisted() public {
        // B: Fail when whitelisting already whitelisted sender
        admin.whitelistExternalSender(user1);
        
        vm.expectRevert("User already whitelisted");
        admin.whitelistExternalSender(user1);
    }

    // ============================================
    // TEST 10: Blacklist External Sender
    // ============================================
    function test_10A_BlacklistExternalSender_Success() public {
        // A: Successfully blacklist external sender
        admin.whitelistExternalSender(user1);
        
        vm.expectEmit(true, false, false, false);
        emit BlackListedExternalSender(user1);
        
        bool success = admin.blacklistExternalSender(user1);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.isExternalSenderWhitelisted(user1), "Should not be whitelisted");
    }

    function test_10B_BlacklistExternalSender_Failure_NotWhitelisted() public {
        // B: Fail when blacklisting non-whitelisted sender
        vm.expectRevert("User not whitelisted");
        admin.blacklistExternalSender(user1);
    }

    // ============================================
    // TEST 11: Internal User Whitelist
    // ============================================
    function test_11A_WhitelistInternalUser_Success() public {
        // A: Successfully whitelist internal user
        vm.expectEmit(true, false, false, false);
        emit WhitelistedInternalUser(user1);
        
        bool success = admin.whitelistInternalUser(user1);
        
        assertTrue(success, "Should return true");
        assertTrue(admin.isInternalUserWhitelisted(user1), "Should be whitelisted");
    }

    function test_11B_WhitelistInternalUser_Failure_AlreadyWhitelisted() public {
        // B: Fail when whitelisting already whitelisted user
        admin.whitelistInternalUser(user1);
        
        vm.expectRevert("User already whitelisted");
        admin.whitelistInternalUser(user1);
    }

    // ============================================
    // TEST 12: Blacklist Internal User
    // ============================================
    function test_12A_BlacklistInternalUser_Success() public {
        // A: Successfully blacklist internal user
        admin.whitelistInternalUser(user1);
        
        vm.expectEmit(true, false, false, false);
        emit BlackListedInternalUser(user1);
        
        bool success = admin.blacklistInternalUser(user1);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.isInternalUserWhitelisted(user1), "Should not be whitelisted");
    }

    function test_12B_BlacklistInternalUser_Failure_NotWhitelisted() public {
        // B: Fail when blacklisting non-whitelisted user
        vm.expectRevert("User not whitelisted");
        admin.blacklistInternalUser(user1);
    }

    // ============================================
    // TEST 13: Add/Remove BlackList
    // ============================================
    function test_13A_AddBlackList_Success() public {
        // A: Successfully add user to blacklist
        vm.expectEmit(true, false, false, false);
        emit AddedBlackList(evilUser);
        
        admin.addBlackList(evilUser);
        
        assertTrue(admin.isBlackListed(evilUser), "User should be blacklisted");
    }

    function test_13B_AddBlackList_Failure_AlreadyBlacklisted() public {
        // B: Fail when adding already blacklisted user
        admin.addBlackList(evilUser);
        
        vm.expectRevert("User already BlackListed");
        admin.addBlackList(evilUser);
    }

    // ============================================
    // TEST 14: Remove from BlackList
    // ============================================
    function test_14A_RemoveBlackList_Success() public {
        // A: Successfully remove user from blacklist
        admin.addBlackList(evilUser);
        
        vm.expectEmit(true, false, false, false);
        emit RemovedBlackList(evilUser);
        
        bool success = admin.removeBlackList(evilUser);
        
        assertTrue(success, "Should return true");
        assertFalse(admin.isBlackListed(evilUser), "User should not be blacklisted");
    }

    function test_14B_RemoveBlackList_Failure_NotBlacklisted() public {
        // B: Fail when removing non-blacklisted user
        vm.expectRevert("Address not a Listed User");
        admin.removeBlackList(evilUser);
    }

    // ============================================
    // TEST 15: Pause/Unpause Functionality
    // ============================================
    function test_15A_Pause_Success() public {
        // A: Successfully pause and verify operations are blocked
        admin.pause();
        
        vm.expectRevert("Pausable: paused");
        admin.addCanMint(user1);
    }

    function test_15B_Unpause_Success() public {
        // B: Successfully unpause and verify operations resume
        admin.pause();
        admin.unpause();
        
        // Should work after unpause
        bool success = admin.addCanMint(user1);
        assertTrue(success, "Should work after unpause");
        assertTrue(admin.canMint(user1), "User1 should be a minter");
    }

    // ============================================
    // BONUS TEST 16: Trusted Contract Can Call Functions
    // ============================================
    function test_16_TrustedContract_CanCallProtectedFunctions() public {
        // Add trusted contract
        admin.addTrustedContract(trustedContractAddr);
        
        // Call from trusted contract
        vm.prank(trustedContractAddr);
        bool success = admin.addCanMint(user1);
        
        assertTrue(success, "Trusted contract should be able to call");
        assertTrue(admin.canMint(user1), "User1 should be a minter");
    }

    // ============================================
    // BONUS TEST 17: Non-Owner Cannot Call Owner Functions
    // ============================================
    function test_17_NonOwner_CannotCallOwnerFunctions() public {
        vm.prank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        admin.addCanForward(user2);
    }
}
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  
  // ============================================
  // CONFIGURATION - UPDATE THESE ADDRESSES
  // ============================================
  
  // Contract addresses (from your deployment)
  const ADMIN_PROXY_ADDRESS = "";
  const FORWARDER_ADDRESS = "";
  const NTZS_PROXY_ADDRESS = "";
  
  // New owner address (where ownership will be transferred)
  const NEW_OWNER_ADDRESS = "";
  
  // New proxy admin address (who will control upgrades)
  const NEW_PROXY_ADMIN_ADDRESS = "";
  
  console.log("Starting ownership transfer process...");
  console.log("Deployer address:", deployer.address);
  console.log("New Owner:", NEW_OWNER_ADDRESS);
  console.log("New Proxy Admin:", NEW_PROXY_ADMIN_ADDRESS);
  console.log("\n" + "=".repeat(50) + "\n");
  
  // ============================================
  // 1. TRANSFER OWNERSHIP OF CONTRACTS
  // ============================================
  
  // Transfer Admin contract ownership
  console.log("1. Transferring Admin contract ownership...");
  const admin = await ethers.getContractAt("Admin", ADMIN_PROXY_ADDRESS);
  
  const currentAdminOwner = await admin.owner();
  console.log("Current Admin owner:", currentAdminOwner);
  
  if (currentAdminOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Warning: You are not the current owner of Admin contract!");
  } else {
    const tx1 = await admin.transferOwnership(NEW_OWNER_ADDRESS);
    await tx1.wait();
    console.log("✓ Admin ownership transferred to:", NEW_OWNER_ADDRESS);
    console.log("Transaction hash:", tx1.hash);
  }
  
  console.log("\n" + "-".repeat(50) + "\n");
  
  // Transfer Forwarder contract ownership
  console.log("2. Transferring Forwarder contract ownership...");
  const forwarder = await ethers.getContractAt("Forwarder", FORWARDER_ADDRESS);
  
  const currentForwarderOwner = await forwarder.owner();
  console.log("Current Forwarder owner:", currentForwarderOwner);
  
  if (currentForwarderOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Warning: You are not the current owner of Forwarder contract!");
  } else {
    const tx2 = await forwarder.transferOwnership(NEW_OWNER_ADDRESS);
    await tx2.wait();
    console.log("✓ Forwarder ownership transferred to:", NEW_OWNER_ADDRESS);
    console.log("Transaction hash:", tx2.hash);
  }
  
  console.log("\n" + "-".repeat(50) + "\n");
  
  // Transfer NTZS contract ownership
  console.log("3. Transferring nTZS contract ownership...");
  const ntzs = await ethers.getContractAt("nTZS", NTZS_PROXY_ADDRESS);
  
  const currentNtzsOwner = await ntzs.owner();
  console.log("Current nTZS owner:", currentNtzsOwner);
  
  if (currentNtzsOwner.toLowerCase() !== deployer.address.toLowerCase()) {
    console.log("Warning: You are not the current owner of nTZS contract!");
  } else {
    const tx3 = await ntzs.transferOwnership(NEW_OWNER_ADDRESS);
    await tx3.wait();
    console.log("✓ nTZS ownership transferred to:", NEW_OWNER_ADDRESS);
    console.log("Transaction hash:", tx3.hash);
  }
  
  console.log("\n" + "=".repeat(50) + "\n");
  
  // ============================================
  // 2. TRANSFER PROXY ADMIN OWNERSHIP
  // ============================================
  
  console.log("4. Transferring Proxy Admin ownership...");
  
  // Get the ProxyAdmin contract address
  const adminProxyAdminAddress = await upgrades.erc1967.getAdminAddress(ADMIN_PROXY_ADDRESS);
  const NTZSProxyAdminAddress = await upgrades.erc1967.getAdminAddress(NTZS_PROXY_ADDRESS);
  
  console.log("Admin Proxy's ProxyAdmin address:", adminProxyAdminAddress);
  console.log("NTZS Proxy's ProxyAdmin address:", NTZSProxyAdminAddress);
  const proxyAdminInstance = await ethers.getContractAt("ProxyAdmin", adminProxyAdminAddress);
  // Transfer ProxyAdmin ownership for Admin proxy
  if (adminProxyAdminAddress !== ethers.constants.AddressZero) {
    console.log("\nTransferring Admin ProxyAdmin ownership...");
   const tx = await proxyAdminInstance.transferOwnership(NEW_PROXY_ADMIN_ADDRESS); // await upgrades.admin.transferProxyAdminOwnership(NEW_PROXY_ADMIN_ADDRESS);
  await tx.wait();
   console.log("✓ ProxyAdmin ownership transferred to:", NEW_PROXY_ADMIN_ADDRESS);
  }
  
  // Note: If both proxies share the same ProxyAdmin (which is typical),
  // the above transfer will handle both. Otherwise, you may need separate transfers.
  
  console.log("\n" + "=".repeat(50) + "\n");
  
  // ============================================
  // 3. VERIFICATION
  // ============================================
  
  console.log("Verifying ownership transfers...\n");
  
  const newAdminOwner = await admin.owner();
  console.log("Admin new owner:", newAdminOwner);
  console.log("Match:", newAdminOwner.toLowerCase() === NEW_OWNER_ADDRESS.toLowerCase() ? "✓" : "✗");
  
  const newForwarderOwner = await forwarder.owner();
  console.log("\nForwarder new owner:", newForwarderOwner);
  console.log("Match:", newForwarderOwner.toLowerCase() === NEW_OWNER_ADDRESS.toLowerCase() ? "✓" : "✗");
  
  const newNtzsOwner = await ntzs.owner();
  console.log("\nnTZS new owner:", newNtzsOwner);
  console.log("Match:", newNtzsOwner.toLowerCase() === NEW_OWNER_ADDRESS.toLowerCase() ? "✓" : "✗");
  
  const proxyAdmin = await ethers.getContractAt(
    "ProxyAdmin",
    adminProxyAdminAddress
  );
  const newProxyAdminOwner = await proxyAdmin.owner();
  console.log("\nProxyAdmin new owner:", newProxyAdminOwner);
  console.log("Match:", newProxyAdminOwner.toLowerCase() === NEW_PROXY_ADMIN_ADDRESS.toLowerCase() ? "✓" : "✗");
  
  console.log("\n" + "=".repeat(50));
  console.log("Ownership transfer complete!");
  console.log("=".repeat(50));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
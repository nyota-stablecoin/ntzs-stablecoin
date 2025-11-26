const { ethers, upgrades } = require("hardhat");

async function main() {
   const proxyAddress = ""; // your proxy address
   const ntzs = await ethers.getContractFactory("Ntzs");
   const [deployer] = await ethers.getSigners();
 
   console.log("Deployer Address:", deployer.address);

   // First, force import the proxy
   console.log("Importing proxy...");
  //  await upgrades.forceImport(proxyAddress, ntzs, { kind: "transparent" });
   
   // Now you can upgrade
   console.log("Deploying ntzs upgrades contract...");
   const upgradeablentzs = await upgrades.upgradeProxy(proxyAddress, ntzs, {
      kind: "transparent"
   });

   console.log("Upgradeable ntzs deployed to:", upgradeablentzs.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
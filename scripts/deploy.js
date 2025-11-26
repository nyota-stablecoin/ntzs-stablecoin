const { ethers, upgrades } = require("hardhat");

async function main() {
  // Deploy the Admin contract
  const [deployer] = await ethers.getSigners();
  const Admin = await ethers.getContractFactory("Admin");

  console.log("Deploying Admin contract...");
  const admin = await upgrades.deployProxy(Admin, [], {
    initializer: "initialize",
    kind: "transparent",
    admin: deployer.address
  });
  await admin.deployed();
  console.log("Admin contract deployed to:", admin.address);


  // Automatically verify the Admin proxy implementation
  const adminImplementationAddress = await upgrades.erc1967.getImplementationAddress(admin.address);
  console.log("Admin Implementation address:", adminImplementationAddress);

  await hre.run("verify:verify", {
    address: adminImplementationAddress,
  });

  // Deploy the Forwarder contract with the adminContract address
  const Forwarder = await ethers.getContractFactory("Forwarder");
  console.log("Deploying Forwarder contract...");
  const forwarder = await Forwarder.deploy(admin.address);
  await forwarder.deployed();
  console.log(
    "Forwarder contract deployed to:",
    forwarder.address
  );

  await hre.run("verify:verify", {
      address: forwarder.address,
      constructorArguments: [admin.address]
    });

  // Deploy the ntzs contract via proxy
  const ntzsContract = await ethers.getContractFactory("Ntzs"); // Move this line before calling `deployProxy`
  console.log("Deploying ntzs contract...");
  const ntzs = await upgrades.deployProxy(
    ntzsContract,
    [forwarder.address, admin.address],
    {
      initializer: "initialize",
      kind: "transparent",
      // unsafeAllow: ["delegatecall"],
    }
  );

  await ntzs.deployed();
  console.log("Upgradeable ntzs Contract deployed to:", ntzs.address);

    // Automatically verify the Admin proxy implementation
    const ntzsImplementationAddress = await upgrades.erc1967.getImplementationAddress(admin.address);
    console.log("ntzs Implementation address:", ntzsImplementationAddress);
  await hre.run("verify:verify", {
      address: ntzsImplementationAddress,
      constructorArguments: [forwarder.address,admin.address], 
    });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

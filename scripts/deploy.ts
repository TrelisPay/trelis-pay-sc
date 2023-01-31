import { ethers } from "hardhat";

async function main() {


  const Subscription = await ethers.getContractFactory("Subscription");
  const subscription = await Subscription.deploy();

  await subscription.deployed();

  console.log(`Subscription contract deployed to ${subscription.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers } from "hardhat";

async function main() {
   const lockDealNFt = ""
   const dealProvider = ""

  const CollateralProvider = await ethers.getContractFactory("CollateralProvider");
  const collateralProvider = await CollateralProvider.deploy(lockDealNFt, dealProvider);
  await collateralProvider.deployed();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

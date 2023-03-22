// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const{BigNumber}=require('ethers');
const { ethers } = require("hardhat");
async function main() {
  [owner] = await ethers.getSigners();
  Token = await ethers.getContractFactory("MyERC20");
  rewardToken = await Token.deploy("USDT","USDT");
  await rewardToken.deployed();
  console.log(
    `rewardToken deployed to ${rewardToken.address}`
  );
  console.log("tx:" + rewardToken.deployTransaction.hash);
  //100000000
  tx = await rewardToken.mint(owner.address, BigNumber.from("100000000000000000000000000"));
  await tx.wait();
  console.log("tx:" + tx.hash);

  TaskReward = await ethers.getContractFactory("TaskReward");

  TaskRewardContract = await TaskReward.deploy(rewardToken.address);
  await TaskRewardContract.deployed();
  console.log(
    `TaskRewardContract deployed to ${TaskRewardContract.address}`
  );
  console.log("tx:" + TaskRewardContract.deployTransaction.hash);
  
  tx = await rewardToken.approve(TaskRewardContract.address, BigNumber.from("100000000000000000000000000"));
  await tx.wait();
  console.log("tx:" + tx.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

const { expect } = require("chai");
const{BigNumber}=require('ethers');
const {ethers} = require("hardhat");
describe("Betting contract", function () {

  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addr4;
  let addr5;


  beforeEach(async function () {
    [owner, addr1, addr2, addr3,addr4,addr5] = await ethers.getSigners();



  });

  describe("tests", function () {
    it("test1", async function () {
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
  });
  });
});
const { expect } = require("chai");
const { ethers } = require("hardhat");
const web3 = require("web3");

describe("Staking", function () {
  let owner 
  let stakeAmount =  web3.utils.toWei("10", "ether")
  before(async function() {
    owner = (await ethers.getSigners())['0'].address;
    TKNToken = await ethers.getContractFactory('TKNToken');
    tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
    await tKNToken.deployed();

    Staking = await ethers.getContractFactory('Staking');
    staking = await Staking.deploy(tKNToken.address);
    await staking.deployed();

    await tKNToken.approve(staking.address, stakeAmount);
    await staking.stake(owner);
  })

  it("should update contract balance correctly", async function(){
    expect((await tKNToken.balanceOf(staking.address)).toString()).to.equal(stakeAmount)
  })

  it("should check that total aggregate stake for actor updated correctly", async function(){
    expect((await staking._aggregateStakeAmount(owner)).toString()).to.equal(stakeAmount)
  })
  it("should create stake index", async function(){
    expect((await staking._stakeIndexes(owner, 1)).exists).to.equal(true)
  })
  it("should update reward snapshot correctly", async function() {
    expect((await staking._rewardSnapshot(owner, 1))).to.equal('0')
  });
  it("should update individual stake correctly", async function() {
    expect((await staking._aggregateStakeAmount(owner)).toString()).to.equal(stakeAmount);
  });
});


// describe("Unstaking", function () {
//   before(async function() {
//     TKNToken = await ethers.getContractFactory('TKNToken');
//     tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
//     await tKNToken.deployed();

//     Staking = await ethers.getContractFactory('Staking');
//     staking = await Staking.deploy(tKNToken.address);
//     await staking.deployed();
//   })

//   it("should check that total amount in contract decreased correctly");
//   it("should check that stake index doesn't exist");
//   it("should check the total aggregated stakes for the user updated correctly");
//   it("should throw an error when wrong stake index is supplied");
// });


// describe("Distribution", function () {
//   before(async function() {
//     TKNToken = await ethers.getContractFactory('TKNToken');
//     tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
//     await tKNToken.deployed();

//     Staking = await ethers.getContractFactory('Staking');
//     staking = await Staking.deploy(tKNToken.address);
//     await staking.deployed();
//   })

//   it("should check that total accrued reward on the system updated correctly");
// });

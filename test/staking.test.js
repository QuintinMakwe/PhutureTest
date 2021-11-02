const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const web3 = require("web3");
const utils = require('../utils/utils');

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

  it("should return right params in event emmitted after stake", async function(){
    await tKNToken.approve(staking.address, stakeAmount);
    await expect(staking.stake(owner)).to.emit(staking, 'TokenStaked').withArgs(2, owner, stakeAmount, (BigNumber.from(stakeAmount).add(stakeAmount)), ['2', true], 0);
  })

  it("should throw error if account doesn't approve enough tokens", async function(){
    await utils.shouldThrow(staking.stake(owner));
  })
});


describe("Unstaking", function () {
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
    await staking.unstake(owner, 1);
  })

  it("should check that total amount in contract decreased correctly", async function(){
    expect((await staking._totalStakedAmount()).toString()).to.equal('0')
  });
  
  it("should throw an error when wrong stake index is supplied", async function() {
    await utils.shouldThrow(staking.unstake(owner, 1))
  });

  it("should check that event values returned is correct", async function() {
    await staking.stake(owner);
    await expect(staking.unstake(owner,2)).to.emit(staking, 'TokenUnstaked').withArgs(2, owner, '0', ['2', false], '0');
  })
});


describe("Distribution", function () {
  let owner
  let distributeValue =  web3.utils.toWei("10", "ether")
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
    await staking.distributeReward(distributeValue);
  })

  it("should check that total accrued reward on the system updated correctly", async function(){
    const totalAccruedReward = 0 + distributeValue/stakeAmount
    expect((await staking._totalAccruedReward()).toString()).to.equal(totalAccruedReward.toString())
  });
});


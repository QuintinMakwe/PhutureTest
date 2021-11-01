const { expect } = require("chai");
const { ethers } = require("hardhat");
const web3 = require("web3");

describe("Staking", function () {
  before(async function() {
    TKNToken = await ethers.getContractFactory('TKNToken');
    tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
    await tKNToken.deployed();

    Staking = await ethers.getContractFactory('Staking');
    staking = await Staking.deploy(tKNToken.address);
    await staking.deployed();
  })

  it("should initialize aggregate staking amount to zero", async function(){
    console.log('running here')
    expect((await staking._totalAccruedReward()).toString()).to.equal('0')
  })

  // it("updates total aggregate stake correctly")
  // it("updates ")
});


describe("Unstaking", function () {
  before(async function() {
    TKNToken = await ethers.getContractFactory('TKNToken');
    tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
    await tKNToken.deployed();

    Staking = await ethers.getContractFactory('Staking');
    staking = await Staking.deploy(tKNToken.address);
    await staking.deployed();
  })

  it("checks", async function(){
    console.log('running here')
    expect((await staking._totalAccruedReward()).toString()).to.equal('0')
  })
});


describe("Distribution", function () {
  before(async function() {
    TKNToken = await ethers.getContractFactory('TKNToken');
    tKNToken= await TKNToken.deploy(web3.utils.toWei('100000000', "ether"))
    await tKNToken.deployed();

    Staking = await ethers.getContractFactory('Staking');
    staking = await Staking.deploy(tKNToken.address);
    await staking.deployed();
  })

  it("should initialize aggregate staking amount to zero", async function(){
    console.log('running here')
    expect((await staking._totalAccruedReward()).toString()).to.equal('0')
  })

  it("updates total aggregate stake correctly")
  it("updates ")
});

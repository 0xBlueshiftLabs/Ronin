
// truffle test test/1_RoninCats_test.js --compile-none


const HonourToken = artifacts.require("HonourToken");

const IRoninCats = artifacts.require("IRoninCats");
const IRoninKittens = artifacts.require("IRoninKittens");

const RoninCats = artifacts.require("RoninCats");
const RoninKittens = artifacts.require("RoninKittens");


var chai = require("./setupchai.js");
const BN = web3.utils.BN;
const expect = chai.expect;

const truffleAssert = require('truffle-assertions');
const { assert } = require('chai');




contract("RoninCats", async accounts => {

    let roninCats;
    let roninKittens;
    let honourToken;
  
    beforeEach(async () => {
        
        roninCats = await RoninCats.deployed();
        roninKittens = await RoninKittens.deployed();

        honourToken = await HonourToken.deployed();

        await roninCats.setHonourTokenAddress(honourToken.address);
        await roninKittens.setHonourTokenAddress(honourToken.address);


    });


    
    it('Default values', async () => { 

      expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(0));

      expect(await roninCats.honourToken()).to.equal(honourToken.address);
      expect(await roninKittens.honourToken()).to.equal(honourToken.address);
     
    });


    it('white listed address can mint during presale', async () => {


        expect(await roninCats.preSaleStatus()).to.eq(false)
        expect(await roninCats.publicSaleStatus()).to.eq(false)
    
        await roninCats.setPreSaleStatus(true)
        expect(await roninCats.preSaleStatus()).to.eq(true)
    
        await roninCats.whitelistAddresses([accounts[3], accounts[4]])
    
        // not on whitelist
        await truffleAssert.reverts(
          roninCats.mint(1, { value: 0.05e18, from: accounts[7] }),
          "Not on whitelist"
        );
    
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(0))
    
        await roninCats.mint(2, { value: 0.1e18, from: accounts[3] })
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(2))
        expect(await roninCats.balanceOf(accounts[3])).to.be.a.bignumber.equal(new BN(2))
    
    
    
        // maximum of 3 mints
        await truffleAssert.reverts(
          roninCats.mint(3, { value: 0.15e18, from: accounts[4] }),
          "Incorrect mint amount"
        );
    
      })
    
      it('set public sale live whilst stopping pre sale', async () => {
    
        expect(await roninCats.preSaleStatus()).to.eq(true)
        expect(await roninCats.publicSaleStatus()).to.eq(false)
    
        await roninCats.setPublicSaleStatus(true)       
    
        expect(await roninCats.preSaleStatus()).to.eq(false)
        expect(await roninCats.publicSaleStatus()).to.eq(true)
    
      })

      it('Can mint at public sale', async () => { 

        expect(await roninCats.publicSaleStatus()).to.eq(true)
        
        await roninCats.mint(2, { value: 0.1e18, from: accounts[8] })
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(4))
        expect(await roninCats.balanceOf(accounts[8])).to.be.a.bignumber.equal(new BN(2))
    
    
    
        // maximum of 3 mints at pre sale
        await truffleAssert.reverts(
          roninCats.mint(3, { value: 0.15e18, from: accounts[4] }),
          "Incorrect mint amount"
        );
       
      });

    
})
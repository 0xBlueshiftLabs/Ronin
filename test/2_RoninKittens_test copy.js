
// truffle test test/2_RoninKittens_test.js --compile-none


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


    
    it('Can harvest tokens', async () => { 


        expect(await roninCats.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0)); 

     
    });

    
})
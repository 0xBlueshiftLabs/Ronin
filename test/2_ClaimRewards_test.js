
// truffle test test/2_ClaimRewards_test.js --compile-none


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
const { duration, increaseTimeTo, latestTime } = require('./utils');




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


    
    it('Can claim reward when currently holding', async () => { 


        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(0));
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0)); 

        await roninCats.setPublicSaleStatus(true)
        expect(await roninCats.publicSaleStatus()).to.eq(true)

        await roninCats.mint(1, { value: 0.05e18 })
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(1));
        expect(await roninCats.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(1));

        // increases timestamp by 1 day
        currentTimeStamp = (await web3.eth.getBlock('latest')).timestamp;
        const moveToDate = currentTimeStamp + duration.days(1);
        await increaseTimeTo(moveToDate);

        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0)); 
        await honourToken.claimReward()
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('10', 'ether'))); 
        expect(await honourToken.viewReward(accounts[0])).to.be.a.bignumber.equal(new BN(0));
     
    });

    it('Can claim residual reward after transfering RoninCats token', async () => { 


        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(1));
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('10', 'ether'))); 

        // increases timestamp by 1 day
        currentTimeStamp = (await web3.eth.getBlock('latest')).timestamp;
        const moveToDate = currentTimeStamp + duration.days(1);
        await increaseTimeTo(moveToDate);

        expect(await honourToken.viewReward(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('10', 'ether'))); 
        
        await roninCats.transferFrom(accounts[0], accounts[1], 1);
        expect(await roninCats.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0));
        expect(await roninCats.balanceOf(accounts[1])).to.be.a.bignumber.equal(new BN(1));

        expect(await honourToken.viewReward(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('10', 'ether'))); 
        expect(await honourToken.viewReward(accounts[1])).to.be.a.bignumber.equal(new BN(0));

        await honourToken.claimReward();

        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('20', 'ether')));
        expect(await honourToken.viewReward(accounts[0])).to.be.a.bignumber.equal(new BN(0));
     
    });

    
})
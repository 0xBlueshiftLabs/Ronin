
// truffle test test/3_Breeding_test.js --compile-none


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
        expect(await roninKittens.totalSupply()).to.be.a.bignumber.equal(new BN(0));
  
        expect(await roninCats.honourToken()).to.equal(honourToken.address);
        expect(await roninKittens.honourToken()).to.equal(honourToken.address);
       
    });

    it('Can breed if you own 2 or more RoninCats and have 600 $HONOUR to burn', async () => { 

        // initial values
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0));
        expect(await honourToken.totalSupply()).to.be.a.bignumber.equal(new BN(0));
        expect(await roninKittens.breedingStatus()).to.be.equal(false);

        // Breeding not live
        await truffleAssert.reverts(
            honourToken.breed(),
            "Breeding is not live"
        );

        await roninKittens.setBreedingStatus(true);
        expect(await roninKittens.breedingStatus()).to.be.equal(true);

        // Doesn't own enough HONOUR tokens
        await truffleAssert.reverts(
            honourToken.breed(),
            "Insufficient $HONOUR tokens to breed"
        );

        await roninCats.setPublicSaleStatus(true)
        expect(await roninCats.publicSaleStatus()).to.eq(true)

        await roninCats.mint(1, { value: 0.05e18 })
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(1));
        expect(await roninCats.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(1));

        // increases timestamp by 20 days
        currentTimeStamp = (await web3.eth.getBlock('latest')).timestamp;
        const moveToDate = currentTimeStamp + duration.days(60);
        await increaseTimeTo(moveToDate);

        // breeder claims 600 $HONOUR
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(0)); 
        await honourToken.claimReward();
        expect(await honourToken.totalSupply()).to.be.a.bignumber.equal(new BN(web3.utils.toWei('600', 'ether')));
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('600', 'ether'))); 
        expect(await honourToken.viewReward(accounts[0])).to.be.a.bignumber.equal(new BN(0));

        // Doesn't own 2 or more RoninCats
        await truffleAssert.reverts(
            honourToken.breed(),
            "Must own at least 2 RoninCats"
        );

        // breeder mints a 2nd RoninCat
        await roninCats.mint(1, { value: 0.05e18 });
        expect(await roninCats.totalSupply()).to.be.a.bignumber.equal(new BN(2));
        expect(await roninCats.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(2));

        await honourToken.breed();

        // checks tokens were transfered from breeder's wallet and burned
        expect(await honourToken.totalSupply()).to.be.a.bignumber.equal(new BN(web3.utils.toWei('0', 'ether')));
        expect(await honourToken.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(web3.utils.toWei('0', 'ether')));

        // checks RoninKitten was minted to breeder
        expect(await roninKittens.totalSupply()).to.be.a.bignumber.equal(new BN(1));
        expect(await roninKittens.balanceOf(accounts[0])).to.be.a.bignumber.equal(new BN(1));
        
       
    });


})
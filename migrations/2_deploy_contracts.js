
const HonourToken = artifacts.require("HonourToken");

const IRoninCats = artifacts.require("IRoninCats");
const IRoninKittens = artifacts.require("IRoninKittens");

const RoninCats = artifacts.require("RoninCats");
const RoninKittens = artifacts.require("RoninKittens");



module.exports = async (deployer) => {
    
    await deployer.deploy(
        RoninCats,
        "RoninCats",
        "RCATS",
        "baseURI",
        "notRevealedURI"
    );

    await deployer.deploy(
        RoninKittens,
        "RoninKittens",
        "RKITS",
        "baseURI"
    );

    await deployer.deploy(
        HonourToken, 
        RoninCats.address, 
        RoninKittens.address
    );


    // await deployer.deploy(MockLLTH).then(res => {
    //     deployer.deploy(Harvest, res.address);
    // })


}
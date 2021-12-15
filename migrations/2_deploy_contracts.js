
const HonourToken = artifacts.require("HonourToken");

const IRoninCats = artifacts.require("IRoninCats");
const IRoninRecruits = artifacts.require("IRoninRecruits");

const RoninCats = artifacts.require("RoninCats");
const RoninRecruits = artifacts.require("RoninRecruits");



module.exports = async (deployer) => {
    
    await deployer.deploy(
        RoninCats,
        "RoninCats",
        "RCATS",
        "baseURI",
        "notRevealedURI"
    );

    await deployer.deploy(
        RoninRecruits,
        "RoninRecruits",
        "RCRT",
        "baseURI"
    );

    await deployer.deploy(
        HonourToken, 
        RoninCats.address, 
        RoninRecruits.address
    );


    // await deployer.deploy(MockLLTH).then(res => {
    //     deployer.deploy(Harvest, res.address);
    // })


}
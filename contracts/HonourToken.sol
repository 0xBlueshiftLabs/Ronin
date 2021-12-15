// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


/**
 * @dev ERC20 token standard
 */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Modifier 'onlyOwner' becomes available, where owner is the contract deployer
 */
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev RoninKittens interface. Inherits from IERC721Enumerable.
 */
import "./IRoninKittens.sol";

/**
 * @dev RoninCats interface. Inherits from IERC721Enumerable.
 */
import "./IRoninCats.sol";


contract HonourToken is ERC20, Ownable {

  uint public dailyReward = 10 ether;

  uint public breedingCost = 600 ether;

  IRoninKittens roninKittens;
  IRoninCats roninCats;

  uint deploymentTimeStamp;

  constructor(
    address _RoninCatsAddress,
    address _RoninKittensAddres
    ) 
    
    ERC20("Honour", "HONOUR") {

      roninCats = IRoninCats(_RoninCatsAddress);
      roninKittens = IRoninKittens(_RoninKittensAddres);

      deploymentTimeStamp = block.timestamp;
  }



  // PUBLIC 
  function claimReward() public {
    
    require(roninCats.balanceOf(msg.sender) > 0 || roninCats.getResidualDays(msg.sender) > 0, "No rewards to claim");
    require(block.timestamp <= deploymentTimeStamp + (24*60*60*365.25*10)); // 10 year limit

    uint reward = _getReward(msg.sender);
  
    _mint(msg.sender, reward);
  }

  function _getReward(address _address) internal returns(uint) {

    uint reward;

    if (roninCats.balanceOf(_address) > 0) {
      for (uint i = 0; i < roninCats.balanceOf(_address); i++) {
        uint tokenId = roninCats.tokenOfOwnerByIndex(_address, i);
        reward += ((block.timestamp - roninCats.getLastClaimStamp(tokenId)) / (24*60*60)) * dailyReward;
        roninCats.setLastClaimStamp(tokenId);
      }
    }
    
    if (roninCats.getResidualDays(_address) > 0) {
      reward += roninCats.getResidualDays(_address) * dailyReward;
      roninCats.resetResidualDays(_address);
    }

    return reward;
  }

  function viewReward(address _address) public view returns(uint) {

    uint reward;

    if (roninCats.balanceOf(_address) > 0) {
      for (uint i = 0; i < roninCats.balanceOf(_address); i++) {
        uint tokenId = roninCats.tokenOfOwnerByIndex(_address, i);
        reward += ((block.timestamp - roninCats.getLastClaimStamp(tokenId)) / (24*60*60)) * dailyReward;
      }
    }
    
    if (roninCats.getResidualDays(_address) > 0) {
      reward += roninCats.getResidualDays(_address) * dailyReward;
    }

    return reward;
  }

  function breed() public {
    require(roninKittens.breedingStatus(), "Breeding is not live");
    require(balanceOf(msg.sender) >= breedingCost, "Insufficient $HONOUR tokens to breed");
    require(roninCats.balanceOf(msg.sender) >= 2, "Must own at least 2 RoninCats");

    _burn(msg.sender, breedingCost);

    address breeder = msg.sender;
    roninKittens.mint(breeder);
  }


  
  // ONLY OWNER //


  // unit = Wei.
  function setBreedingCost(uint _cost) public onlyOwner {
    breedingCost = _cost;
  }

  // unit = Wei.
  function setDailyReward(uint _dailyReward) public onlyOwner {
    dailyReward = _dailyReward;
  }
  
}

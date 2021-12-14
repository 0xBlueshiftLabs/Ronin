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

  uint dailyReward = 10 ether;

  bool breedingStatus;
  uint breedingCost = 200 ether;

  IRoninKittens roninKittens;
  IRoninCats roninCats;

  uint deploymentTimeStamp;

  constructor(
    address _RoninKittensAddres, 
    address _RoninCatsAddress
    ) 
    
    ERC20("Honour", "HONOUR") {

      roninKittens = IRoninKittens(_RoninKittensAddres);
      roninCats = IRoninCats(_RoninCatsAddress);

      deploymentTimeStamp = block.timestamp;
  }



  // PUBLIC 
  function claimReward() public {

    require(roninCats.balanceOf(msg.sender) > 0 || roninCats.getResidualDays(msg.sender) > 0, "No rewards to claim");
    require(block.timestamp <= deploymentTimeStamp + (24*60*60*365.25*10)); // 10 year limit

    uint reward;

    if (roninCats.balanceOf(msg.sender) > 0) {
      for (uint i = 0; i < roninCats.balanceOf(msg.sender); i++) {
        uint tokenId = roninCats.tokenOfOwnerByIndex(msg.sender, i);
        reward += getReward(tokenId);
        roninCats.setLastClaimStamp(tokenId);
      }
    }
    
    if (roninCats.getResidualDays(msg.sender) > 0) {
      reward += roninCats.getResidualDays(msg.sender) * dailyReward;
      roninCats.resetResidualDays(msg.sender);
    }
  
    _mint(msg.sender, reward);
  }

  function getReward(uint _tokenId) public view returns(uint) {
    uint reward = ((block.timestamp - roninCats.getLastClaimStamp(_tokenId)) / (24*60*60)) * dailyReward;
    return reward;
  }

  function breed() public {
    require(breedingStatus, "Breeding is not live");
    require(balanceOf(msg.sender) >= breedingCost, "Insufficient HONOUR to breed");
    require(roninCats.balanceOf(msg.sender) >= 2, "Must own at least 2 RoninCats");

    _burn(msg.sender, breedingCost);

    address breeder = msg.sender;
    roninKittens.mint(breeder);
  }


  
  // ONLY OWNER //

  function setBreedingStatus(bool _live) public onlyOwner {
    breedingStatus = _live;
  }

  // unit = Wei.
  function setBreedingCost(uint _cost) public onlyOwner {
    breedingCost = _cost;
  }

  // unit = Wei.
  function setDailyReward(uint _dailyReward) public onlyOwner {
    dailyReward = _dailyReward;
  }
  
}

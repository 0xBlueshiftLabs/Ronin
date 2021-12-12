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

  constructor(
    address _RoninKittensAddres, 
    address _RoninCatsAddress
    ) 
    
    ERC20("Honour", "HONOUR") {

      roninKittens = IRoninKittens(_RoninKittensAddres);
      roninCats = IRoninCats(_RoninCatsAddress);
  }



  // PUBLIC 
  function claimReward() public {

    require(roninCats.balanceOf(msg.sender) > 0, "You don't own any tokens");

    uint reward;
    for (uint i = 0; i < roninCats.balanceOf(msg.sender); i++) {
      uint tokenId = roninCats.tokenOfOwnerByIndex(msg.sender, i);
      reward += getReward(tokenId);
      roninCats.setLastClaimStamp(tokenId);
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
    require(roninCats.balanceOf(msg.sender) >= 2, "Must own at least 2 ");

    // burn msg.sender's breedCost amount of tokens

    address breeder = msg.sender;
    //roninKittens.mint(breeder)
  }


  


  function setBreedingStatus(bool _live) public onlyOwner {
    breedingStatus = _live;
  }

  function setBreedingCost(uint _cost) public onlyOwner {
    breedingCost = _cost;
  }

  function setDailyReward(uint _dailyReward) public onlyOwner {
    dailyReward = _dailyReward;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IRoninKittens is IERC721Enumerable{

    function mint(address _to) external;

    function honourToken() external view returns(address);

    function breedingStatus() external view returns(bool);
  
}



// MIGHT ONLY NEED TO BE IERC721Enumerable.sol
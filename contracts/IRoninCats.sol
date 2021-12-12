// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IRoninCats is IERC721Enumerable{
  
    /**
     * @dev Sets timestamp of the last rewards claim for token '_tokenId'
     *
     * Note: msg.sender must be the HonourToken contract
     */
    function setLastClaimStamp(uint _tokenId) external;

    /**
     * @dev View timestamp of the last rewards claim for token '_tokenId'
     */
    function getLastClaimStamp(uint _tokenId) external view returns(uint);

}

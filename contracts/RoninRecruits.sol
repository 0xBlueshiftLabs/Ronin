// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


/**
 * @dev ERC721 token standard
 */
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @dev Modifier 'onlyOwner' becomes available, where owner is the contract deployer
 */
import "@openzeppelin/contracts/access/Ownable.sol";


contract RoninRecruits is ERC721Enumerable, Ownable {

  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public maxSupply = 500;

  bool public breedingStatus;

  address public honourToken;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  event TokenMinted(uint tokenId);


  function mint(address _to) external {
   
    require(
      msg.sender == honourToken || msg.sender == owner(),
      "Function only callable by HonourToken contract."
    );

    require(breedingStatus, "Breeding is not live");
    require(totalSupply() + 1 <= maxSupply, "Max supply reached");

    uint tokenId = totalSupply() + 1;
    _safeMint(_to, tokenId);

    emit TokenMinted(tokenId);
  }


  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  // internal //
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setHonourTokenAddress(address _address) public onlyOwner {
    honourToken = _address;
  }

  function setBreedingStatus(bool _live) public onlyOwner {
    breedingStatus = _live;
  }
}

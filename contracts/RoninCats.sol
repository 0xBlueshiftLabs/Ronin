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


contract RoninCats is ERC721Enumerable, Ownable {

  using Strings for uint256; 

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 1000;
  uint256 public maxMintAmount = 2;
  bool public revealed = false;
  string public notRevealedUri;

  bool public preSaleStatus;
  bool public publicSaleStatus;

  address public honourToken;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // EVENTS //

  event TokenMinted(uint tokenId);


  // MAPPINGS //

  mapping(address => bool) whitelist;

  mapping(uint => uint) lastClaimStamp; // tokenId => timestamp.

  mapping(address => uint) residualDays; // address => number of days worth of unclaimed HONOUR due to ERC721 token transfer


  // public
  function mint(uint256 _mintAmount) public payable {
   
    require(preSaleStatus || publicSaleStatus, "Minting not live");
    require(_mintAmount > 0 && _mintAmount <= maxMintAmount, "Incorrect mint amount");
    require(totalSupply() + _mintAmount <= maxSupply, "Minting that many would exceed max supply");

    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintAmount);
    }

    if (preSaleStatus) {
      if (msg.sender != owner()) {
        require(whitelist[msg.sender], "Not on whitelist");
      }
    }

    for (uint256 i = 0; i < _mintAmount; i++) {
      uint tokenId = totalSupply() + 1;
      _safeMint(msg.sender, tokenId);
      emit TokenMinted(tokenId);
      lastClaimStamp[tokenId] = block.timestamp;
    }
  }

  function setLastClaimStamp(uint _tokenId) external {
    require(msg.sender == honourToken, "Function only callable by HonourToken contract");
    lastClaimStamp[_tokenId] = block.timestamp;
  }

  function resetResidualDays(address _address) external {
    require(msg.sender == honourToken, "Function only callable by HonourToken contract");
    residualDays[_address] = 0;
  }

  
  function getLastClaimStamp(uint _tokenId) external view returns(uint) {
    return lastClaimStamp[_tokenId];
  }
  
  function getResidualDays(address _address) external view returns(uint) {
    return residualDays[_address];
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }



  


  function transferFrom(address from, address to, uint256 tokenId) public override {
    updateRewards(from, tokenId);
    ERC721.transferFrom(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    updateRewards(from, tokenId);
    ERC721.transferFrom(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
    updateRewards(from, tokenId);
    ERC721.safeTransferFrom(from, to, tokenId, _data);
  }

  function updateRewards(address from, uint256 tokenId) internal {
    residualDays[from] = ((block.timestamp - lastClaimStamp[tokenId])) / (24*60*60);
    lastClaimStamp[tokenId] = block.timestamp;
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
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  // internal //
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // ONLY OWNER //
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setPreSaleStatus(bool _state) public onlyOwner {
    publicSaleStatus = false;
    preSaleStatus = _state;
  }

  function setPublicSaleStatus(bool _state) public onlyOwner {
    preSaleStatus = false;
    publicSaleStatus = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }

  function setHonourTokenAddress(address _address) public onlyOwner {
    honourToken = _address;
  }

  /**
    * @dev Add addresses to whitelist, giving access to the pre sale
    * @param _addresses - array of address' that tokens will be sent to ["address","address",...]
    */
  function whitelistAddresses(address[] calldata _addresses) external onlyOwner {
    for (uint i=0; i<_addresses.length; i++) {
        whitelist[_addresses[i]] = true; 
    }
  }
}

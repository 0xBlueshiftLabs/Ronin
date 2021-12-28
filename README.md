# Ronin Cats, Recruits and $HONOUR token

<p align="center">
  <img width="1080" height="350" src="/banner.png">
</p>

## $HONOUR token

Each Cat will accrue 10 $HONOUR every 24 hours. $HONOUR can be claimed at any point and will be used to recruit new cats for your clan. $HONOUR will provide extra utility when the battle begins and will be used for cosmetic in-game purchases. Any unclaimed $HONOUR is still claimable after a transfer of ownership.


## Recruiting

When a holder of 2 or more Ronin Cats has enough $HONOUR, they will be able to begin recruiting. There are five types of cats you can recruit for your clan: Merchants, Craftsman, Samurai, Daimyo, and of course, Musicians. Each type of cat will have a different play style and can be used in conjunction with your other cats for unique combinations and strategies.

- Burn 600 $HONOUR to mint a “Ronin Recruit”
- Must be holding 2 Ronin Cat NFTs
- Total supply of 500

## Deployment instructions

- Ensure all 5 contracts are in the same directory.
- Deploy RoninCats
- Deploy RoninKittens
- Deploy HonourToken. Parameters are the addresses of RoninCats and RoninKittens.
- Call setHonourTokenAddress() function on RoninCats contract, where the input argument is the address of the HonourToken contract
- Call setHonourTokenAddress() function on RoninKittens contract, where the input argument is the address of the HonourToken contract

### Note: 

- preSaleStatus and publicSaleStatus are set to false by default. Only one can be live at any one time. Setting either one to true or false will automatically set the other to false.
- breedingStatus is set to false by default. Until it is set to true (using the setBreedStatus() function on the RoninKittens contract), RoninKittens cannot be minted by calling breed() function on HonourToken contract.

- Rewards can be claimed by calling claimReward() on the HonourToken contract.
- Outstanding amount of HONOUR that can be claimed can be viewed by calling viewReward() on the HonourToken contract. Unit is Wei (standard practice) where 1 HONOUR = 1*10^18 Wei.








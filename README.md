

# TO DO

# Deployment instructions

- Ensure all 5 contracts are in the same directory.
- Deploy RoninCats
- Deploy RoninKittens
- Deploy HonourToken. Parameters are the addresses of RoninCats and RoninKittens.
- Call setHonourTokenAddress() function on RoninCats contract, where the input argument is the address of the HonourToken contract
- Call setHonourTokenAddress() function on RoninKittens contract, where the input argument is the address of the HonourToken contract

Note: 

- preSaleStatus and publicSaleStatus are set to false by default. Only one can be live at any one time. Setting either one to true or false will automatically set the other to false.
- breedingStatus is set to false by default. Until it is set to true (using the setBreedStatus() function on the RoninKittens contract), RoninKittens cannot be minted by calling breed() function on HonourToken contract.

- Rewards can be claimed by calling claimReward() on the HonourToken contract.
- Outstanding amount of HONOUR that can be claimed can be viewed by calling viewReward() on the HonourToken contract. Unit is Wei (standard practice) where 1 HONOUR = 1*10^18 Wei.






### Airdropping

- Holders of a Ronin Cat NFT will receive 70 $HONOUR every week for 10 years


### Breeding

- Burn 600 $HONOUR to receive a “Ronin Kitten”
- Must be holding 2 Ronin Cat NFT’s
- Only 500 total circulating supply of “Ronin Kittens”




// QUESTIONS //

10 HONOUR per day, or 70 HONOUR per week? I.e. can people claim daily or weekly?

Do you want unclaimed HONOUR to be lost upon RoninCat NFT transfer, or does the new HONOUR inherit the unclaimed reward?
Kongz contract lets user keep unclaimed reward. I say we just pay out thier reward upon transfer because easier to implement.


10 year limit on HONOUR rewards claims from time of contract deployment, ok?



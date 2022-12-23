# PSChiaRPC
 Powershell Chia RPC wrapper

# Install
1. Clone the git hub repo
2. Initiate the app by typing 

```powershell
cd PSChiaRPC
. .\boot.ps1
```

# Dutch Auction
    Example: Start-DutchAuctionForNFT -nft_id nft..... -price_in_xch 2 -decrese_by 0.05 -minutes 20 -min_price_in_xch 0.65
    -- This will start an auction at 2xch and drop it by 0.05xch every 20 minutes until it reaches 0.65XCH

    Parameters:
     - $nft_id = The NFT ID that will be used for the auction.  You can copy it from your chia wallet.
     - $price_in_xch = The starting price of your offer in XCH (not Mojo).
     - $min_price_in_xch = The price will not go under this amount.  
     - $decrease_by = The amount the auction will drop every interval.
     - $minutes = The number of minutes between each interval.
     - $post_to_discord = Boolean switch that will post a message to a discord webhook
     -- config.ps1 needs to be edited with discord = 'https:xxx-webhookaddress'
# PSChiaRPC
 Powershell Chia RPC wrapper

# Install
1. Clone the git hub repo
2. Initiate the app by typing 

```powershell
cd PSChiaRPC
. .\boot.ps1
```

# Config.ps1
    To changes config valuse, edit the .\config.ps1 file and change the values.
```powershell
# Copy this file to config.ps1

$config =[PSCustomObject]@{

    useCatValuesAsMojo = $true;
    #useCatValuesAsMojo = $false;

    useNameForWalletId = $true;
    #useNameForWalletId = $false;

    fee = 0;
    coinArray = @{};

    #discord = 'webhook https'
}

$global:config = $config

```

## useCatValuesAsMojo [$true / $false]
    This setting determines if you wish to use 1 to represent 1XCH or 1CAT2 or if you with to use the Mojo Values like 1000000000000 for XCH or 1000 for CAT2
    
## useNameForWalletId [$true / $false]
    The Chia RPC works off of wallet ID numbers.  To make the program easier to use set this to true and you can use the name of the wallet instead of the number.

## fee [number]
    Default fee to be used in all transactions

## coinarray
    Placeholder for wallet_ids

## discord
    Enter your discord webhook address if you wish to use discord notifications.

# Wallet RPC

## Invoke-CatSpend
    Send CAT2 token to an address.

    Example:
        Invoke-CatSpend -wallet_id 'Stably USD' -amount 100 -inner_address xch...... -fee 0.00005
        
    Parameteres:
        - $wallet_id = Name or number of wallet (based on config.ps1)
        - $amount = Amount to send (as full CAT2 or as Mojo based on config.ps1)
        - $fee = Amount to use as fee (default set in config.ps1)
        - $inner_address = The XCH address to send to
        - $memo = Memo
        - $min_coin_amount Used to select a specific coin size

## Invoke-GetWalletBallance







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
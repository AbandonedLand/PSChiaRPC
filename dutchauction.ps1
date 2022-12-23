<#
    This starts a dutch auction for an NFT.  Only one can run per open powershell window.

    Example: Start-DutchAuctionForNFT -nft_id nft..... -price_in_xch 2 -decrese_by 0.05 -minutes 20 -min_price_in_xch 0.65
    -- This will start an auction at 2xch and drop it by 0.05xch every 20 minutes until it reaches 0.65XCH

    Parameters:
     - $nft_id = The NFT ID that will be used for the auction.  You can copy it from your chia wallet.
     - $price_in_xch = The starting price of your offer in XCH (not Mojo).
     - $min_price_in_xch = The price will not go under this amount.  
     - $decrease_by = The amount the auction will drop every interval.
     - $minutes = The number of minutes between each interval.
#>

Function Start-DuctchAuctionForNFT{
    param(
        [Parameter(Mandatory=$true)]
        [string]$nft_id,
        [Parameter(Mandatory=$true)]
        [decimal]$price_in_xch,
        [decimal]$min_price_in_xch = 0,
        [Parameter(Mandatory=$true)]
        [decimal]$decrease_by,
        [Parameter(Mandatory=$true)]
        [int]$minutes,
        [switch]
        $post_to_discord
    )
    <#
        Converting the NFT ID to the Launcher ID needed for the Chia RPC.
        The section uses MintGarden for the lookup
    #>
    Write-Host "Looking up launcher ID from NFT ID on Mintgarden.com"
    $uri = -join('https://api.mintgarden.io/nfts/',$nft_id)
    $id = (Invoke-RestMethod -Method Get -Uri $uri).id
    $launcher_id = -join("0x",$id)
    <#
        Exit if cannot get launcher ID
    #>
    if(-NOT $launcher_id){
        Write-Host -ForegroundColor Red "Failed to get launcher ID, aborting..."
        return 'Failed';
    }

    while($price_in_xch -gt 0){
        Write-Host "Creating offer"
        <#
            Making the offer
        #>
        $response = Invoke-ChiaOfferNFTforXCH -price_in_xch $price_in_xch -launcher_id $launcher_id
        <#
            Posting to discord Webhook if option is set and Config File is setup correctly
        #>
        if($post_to_discord.IsPresent){
            $content = $response.Content | ConvertFrom-Json
            # Creating the url for dexie offer
            $dexie_offer_uri = -join('https://dexie.space/offers/',$content.id)
            
            # Message to push to discord
            $content = -join("Current Price: ",$price_in_xch," XCH `n Next Update in: ",$minutes," minutes `n",$dexie_offer_uri)

            Submit-ToDiscord -content $content
            
        }


        $price_in_xch = $price_in_xch - $decrease_by
        <#
            Check if the next decrease is below the minimum amount and exit if so
        #>
        if($price_in_xch -lt $min_price_in_xch){
            Write-Host "Minimum amount has been reached"
            break;
        }
        Write-Host "Waiting for $minutes minutes"
        Start-Sleep -Seconds ($minutes * 60)
        
        $dexie_uri = -join('https://api.dexie.space/v1/offers?offered=',$nft_id)
        Write-Host "Checking if offer exists on dexie"
        $dexie = Invoke-RestMethod -Method Get -Uri $dexie_uri
        if($dexie.offers.Length -eq 0 ){
            Write-Host "Auction Sold at " $price_in_xch
            break;
        }
    }


}

<#
    Simpler Function to list an NFT for XCH on Dexie. 
    Examples:

    Invoke-ChiaOfferNFTforXCH -price_in_xch 1 -launcher_id 0x1234567890abcdefxxxxxxxxxxxxxxx
    
#>
Function Invoke-ChiaOfferNFTforXCH{
    param(
        [decimal]$price_in_xch,
        [string]$launcher_id
    )

    $offer = [ChiaOffer]::new()
    $offer.offerednft($launcher_id)
    $offer.requestxch($price_in_xch)
    $offer.createoffer()
    $offer.postToDexie()
    return $offer.dexie_response
}

function Submit-ToDiscord {

    param(
        $content
    )

    $discordBotUrl = $config.discord
    $payload = [PSCustomObject]@{

        content = $content

}

$data = Invoke-RestMethod -Uri $discordBotUrl -Method Post -Body ($payload | ConvertTo-Json) -ContentType 'Application/Json'

}
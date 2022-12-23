vFunction Start-DuctchAuctionForNFT{
    param(
        
        [string]$nft_id,
        [decimal]$price_in_xch,
        [decimal]$decrease_by,
        [int]$minutes
    )
    Write-Host "Looking up launcher ID from NFT ID on Mintgarden.com"
    $uri = -join('https://api.mintgarden.io/nfts/',$nft_id)
    $id = (Invoke-RestMethod -Method Get -Uri $uri).id
    $launcher_id = -join("0x",$id)

    $launcher_id

    while($price_in_xch -gt 0){
        Write-Host "Creating offer"
        Invoke-ChiaOfferNFTforXCH -price_in_xch $price_in_xch -launcher_id $launcher_id

        $price_in_xch = $price_in_xch - $decrease_by

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
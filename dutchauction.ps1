Fucntion Start-DuctchAuctionForNFT{
    param(
        
        [string]$launcher_id,
        [decimal]$price_in_xch,
        [decimal]$decrease_by,
        [int]$minutes
    )

    while($price_in_xch -gt 0){
        Write-Host "Creating offer"
        Invoke-ChiaOfferNFTforXCH -price_in_xch $price_in_xch -launcher_id $launcher_id

        $price_in_xch = $price_in_xch - $decrease_by
        
        Start-Sleep -Seconds ($minutes * 60)
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
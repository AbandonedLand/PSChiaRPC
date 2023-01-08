<# 
    RPC Endpoints for Chia Wallet
#>

<#  
    Make Alias for Chia.exe
#>
if($PSVersionTable.OS -like "*Windows*"){
    $starting_loc = -join($home,"\AppData\Local\chia-blockchain\")
    $beta = -join($home,"\AppData\Local\Programs\Chia\resources\app.asar.unpacked\daemon\")
    # Find the Chia App Version number based on the folder
    $version = (Get-ChildItem -Path $starting_loc -Filter "app*").Name
    $path = -join ($starting_loc,$version,"\resources\app.asar.unpacked\daemon\chia.exe")
    if(Test-Path($path)){
        Set-Alias -Name Chia -Value (-join ($starting_loc,$version,"\resources\app.asar.unpacked\daemon\chia.exe"))
    }
    if(Test-Path($beta)){
        Set-Alias -Name Chia -Value (-join ($beta,"chia.exe"))
    }
}

<#
    Edit the JSON file for windows
#>
function Edit-ChiaRpcJson {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, mandatory)]
        [string] $Json
    )
    # Escape JSON Quotes on powershell version 7.2 and below
    if($PSVersionTable.OS -like "*Windows*" -AND $PSVersionTable.PSVersion.Minor -eq 2){
        $Json -replace '"', '\"'    
    } else {
        $Json
    }
    
}

<#
    Class used to do auto fill (tab selection) and validation of names of CATS
#>
Class SupportedCoins : System.Management.Automation.IValidateSetValuesGenerator{
    [string[]] GetValidValues()
    {
        if($global:config.useNameForWalletId){
            # Get all Coin Names as listed in your chia wallet
            $coins = $global:config.coinArray | Select-Object -ExpandProperty Keys
            # Make all the coin names valid for this selection
            return $Coins
        }
        # If not using wallet names, then wallet IDs 1 - 99 are valid.  
        return 1..99
    }
}

<#
    This will retrieve Wallet IDs
#>
function Invoke-GetWallets{
    $data = (chia rpc wallet get_wallets | convertfrom-json).wallets 
    return $data
}

<#
    Send a CAT2 Token to another address:
    Invoke-CatSpend -wallet_id 'Stably USD' -amount 100 -inner_address xch...... -fee 0.00005
#>
function Invoke-CatSpend {
    param (
    [ValidateSet([SupportedCoins])]
    [Parameter(mandatory=$true)]
    $wallet_id,
    [Parameter(mandatory=$true)]
    $amount,
    $fee = $config.fee,
    [Parameter(mandatory=$true)]
    $inner_address,
    $memo = 'Created with PSChiaRPC',
    $min_coin_amount = 0
    )

    # If using Cat Values, then it must convert to mojos ( default is 1000 )
    if($config.useCatValuesAsMojo){
        $amount = $amount * 1000
    }
    # If using Cat Names for Wallets, then it must convert to the wallet ID to process.
    if($config.useNameForWalletId){
        # Reset the valid range for variable to numbers 2 - 99.  ID 1 is used for XCH and should not be used in CAT spends.
        [ValidateRange(2,99)]$wallet_id = $config.coinArray.($wallet_id).id
    }
     
    # Building JSON object from paramaters and converting it as needed for the RPC command
    $json = [PSCustomObject]@{
        wallet_id = $wallet_id
        amount = $amount
        fee = $fee
        inner_address = $inner_address
        memo = $memo
        min_coin_amount = $min_coin_amount
    } | ConvertTo-Json | Edit-ChiaRpcJson
    
    # Running RPC command
    $response = (chia rpc wallet cat_spend $json) | ConvertFrom-Json

    
    return $response
}

function Invoke-GetWalletBallance{
    param(
        [ValidateSet([SupportedCoins])]
        [Parameter(mandatory=$true)]
        $wallet_id
    )

    if($config.useNameForWalletId){
        # Reset the valid range for variable to numbers 1 - 99.
        [ValidateRange(1,99)]$wallet_id = $config.coinArray.($wallet_id).id
    }

    $json = [PSCustomObject]@{
        wallet_id = $wallet_id
    } | ConvertTo-Json | Edit-ChiaRpcJson

    $response = (chia rpc wallet get_wallet_balance $json | ConvertFrom-Json)
    return $response
}

function Invoke-CancelOffer{
    param(
        $trade_id,
        $fee = $config.fee,
        $secure = $true
    )

    $json = [PSCustomObject]@{
        trade_id = $trade_id
        fee = $fee
        secure = $secure
    } | ConvertTo-Json | Edit-ChiaRpcJson

    $response = (chia rpc wallet cancel_offer $json) | ConvertFrom-Json
    return $response
}

<#
    Chia offer class is a tool to create offers easier.
#>
Class ChiaOffer{
    [hashtable]$offer
    $coins
    $fee
    $offertext
    $json
    $dexie_response
    $dexie_url 
    $abandoned_land_response


    ChiaOffer(){
        $this.coins = $global:config.coinArray
        $this.fee = $global:config.fee
        $this.offer = @{}
        
        $this.dexie_url = "https://dexie.space/v1/offers"
    }

    setTestNet(){
        $this.dexie_url = "https://api-testnet.dexie.space/v1/offers"
    }

    offerednft($launcher_id){
        $this.offer.($launcher_id)=-1
    }

    requested($coin, $amount){
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*1000))
    }

    requestxch($Amount){
        $coin = 'Chia Wallet'
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*1000000000000))
        
    }

    offerxch($Amount){
        $coin = 'Chia Wallet'
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*-1000000000000))
        
    }

    offered($coin, $amount){
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*-1000))
    }
    
    makejson(){
        $this.json = (@{"offer"=($this.offer); "fee"=$this.fee} | convertto-json | Edit-ChiaRpcJson)
    }

    createoffer(){
        $this.makejson()
        $this.offertext = chia rpc wallet create_offer_for_ids $this.json
    }
    
    postToDexie(){
        $data = $this.offertext | convertfrom-json
        $body = @{
            "offer" = $data.offer
        }
        $contentType = 'application/json' 
        $json_offer = $body | convertto-json
        $this.dexie_response = Invoke-WebRequest -Method POST -body $json_offer -Uri $this.dexie_url -ContentType $contentType
    }


}

Function Invoke-GetAllOffers{
    param(
        [int]$start= 0,
        [int]$end = 10,
        [bool]$exclude_my_offers,
        [bool]$exclude_taken_offers,
        [bool]$include_completed,
        
        [bool]$reverse,
        [bool]$file_contents
    )

    $json = [PSCustomObject]@{
        start = $start
        end = $end
        exclude_my_offers = $exclude_my_offers
        exclude_taken_offers = $exclude_taken_offers
        include_completed = $include_completed
        
        reverse = $reverse
        file_contents = $file_contents
    } | ConvertTo-Json | Edit-ChiaRpcJson

    $response = (chia rpc wallet get_all_offers $json | ConvertFrom-Json)
    return $response

}

Function Invoke-GetOffer{
    param(
        $trade_id,
        [switch]
        $file_contents
    )

    if($file_contents.isPresent){
        $json = [PSCustomObject]@{
            trade_id = $trade_id
            file_contents = $true
        } | ConvertTo-Json | Edit-ChiaRpcJson
    } else {
        $json = [PSCustomObject]@{
            trade_id = $trade_id
            file_contents = $false
        } | ConvertTo-Json | Edit-ChiaRpcJson
    }

    $response = (chia rpc wallet get_offer $json | ConvertFrom-Json)
    return $response
}
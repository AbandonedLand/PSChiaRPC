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
            $coins = (Create-CoinArray) | Select-Object -ExpandProperty Keys
            return $Coins
        }
        return 2..99
    }
}




<#
    This will retrieve Wallet IDs
#>
function Invoke-GetWallets{
    $data = (chia rpc wallet get_wallets | convertfrom-json).wallets 
    return $data
}




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

    if($config.useCatValuesAsMojo){
        $amount = $amount * 1000
    }
    if($config.useNameForWalletId){
        # Reset the valid range for variable 
        [ValidateRange(2,999)]$wallet_id = $config.coinArray.($wallet_id).id
    }
     
    $json = [PSCustomObject]@{
        wallet_id = $wallet_id
        amount = $amount
        fee = $fee
        inner_address = $inner_address
        memo = $memo
        min_coin_amount = $min_coin_amount
    } | ConvertTo-Json | Edit-ChiaRpcJson
    
    $response = (chia rpc wallet cat_spend $json) | ConvertFrom-Json
    return $response
}
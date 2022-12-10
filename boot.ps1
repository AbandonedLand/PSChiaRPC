<#
    
    Create the config.ps1 file if it does not exist.

#>
function Import-PSChiaRpcConfiguration{
    if (Test-Path -Path .\config.ps1)
    {
        Write-Host -ForegroundColor Green "Loading Configuration..."
        . .\config.ps1
    }
    else {
        if(Test-Path -Path .\config_example.ps1)
            {
            Copy-Item -Path .\config_example.ps1 -Destination .\config.ps1
            if (Test-Path -Path .\config.ps1)
            {
                Write-Host -ForegroundColor Green "Created config file (config.ps1) with default values"
                . .\config.ps1
                Write-Host -ForegroundColor Green "Loading Configuration..."
            }
            else
            {
                Write-Host -ForegroundColor Red "Unable to create config file."
                Write-Host -ForegroundColor Yello "Please change directory to where the this is installed."
            }

        }
    }
}


<#
    Import-PSChiaRPCFiles will add all the needed files and classes into the runtime.
#>

function Import-PSChiaRPCFiles{
    . .\wallet.ps1
    . .\dexie.ps1
    
}

<#
    Calling the Functions to create config and load files
#>

. Import-PSChiaRpcConfiguration
. Import-PSChiaRPCFiles


<#
    Create-CoinArray
    Converts CAT name to wallet id and loads it into the config
    Chia must be running in order for this to function
#>
function Update-CoinArray{
    $data = Invoke-GetWallets
    $coins = @{}
    foreach($item in $data){
        $coins.($item.name) =@{}
        $coins.($item.name).id = $item.id
    }
    
    $config.coinArray = @{}
    $config.coinArray = $coins
} 

<#
    Update Running Config with Current Coins
#>
. Update-CoinArray

<#
    Adding current config into a global variable
#>
$global:config = $config



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


function Import-PSChiaRPCFiles{
    . .\wallet.ps1
    . .\dexie.ps1
    
}

. Import-PSChiaRpcConfiguration
. Import-PSChiaRPCFiles


<#
    Create-CoinArray
    Converts CAT name to wallet id
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
$global:config = $config



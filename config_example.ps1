# Copy this file to config.ps1

$config =[PSCustomObject]@{
    <# 
        Use RPC Values as Mojo or Cat
        Example: Sending 1 USDS to an address
            (true)  : Invoke-CatSpend -wallet_id 'USDS' -amount 1000 -fee 50000000 -inner_address xchXXXXXX -memo "enter memo" -min_coin_amount 500
            (false) : Invoke-CatSpend -wallet_id 'USDS' -amount 1 -fee .00005 -inner_address xchXXXXXX -memo "enter memo" -min_coin_amount 0.5
    #>
    
    useCatValuesAsMojo = $true;
    #useCatValuesAsMojo = $false;

    <# 
        Use the wallet name as the wallet id
        Example: Sending USDS from wallet 2 to an address  
            (true)  : Invoke-CatSpend -wallet_id 'USDS' -amount 1000 -fee 50000000 -inner_address xchXXXXXX -memo "enter memo" -min_coin_amount 500
            (false) : Invoke-CatSpend -wallet_id 2 -amount 1000 -fee 50000000 -inner_address xchXXXXXX -memo "enter memo" -min_coin_amount 500
    #>
    useNameForWalletId = $true;
    #useNameForWalletId = $false;

    fee = 0;
    coinArray = @{};
    
    <#
        If you wish to use discord webhooks, enter the webhook address below.
    #>
    #discord = 'webhook https'
}

$global:config = $config
function Get-XCHPrice{
    
    $api = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=chia"
    $request = ConvertFrom-Json(Invoke-WebRequest $api)

    
    return [math]::Round([decimal]$request.current_price * 1.005,2)
    
}
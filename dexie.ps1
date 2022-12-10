
function Get-XCHPrice{
    $api = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=chia"
    $request = ConvertFrom-Json(Invoke-WebRequest $api)
    return [math]::Round([decimal]$request.current_price,2)
    
}

function Get-DexieOffers {
    param( 
        [ValidateSet(0,1,2,3,4,5)]
        $status = 0, 
        [Parameter(Mandatory=$true)]
        $requested,
        $requested_min_amount,
        [Parameter(Mandatory=$true)]
        $offered,
        $offered_min_amount,
        [ValidateSet('price','price_desc','date_completed','date_found')]
        $sort = 'price', # price | price_desc | date_completed | date_found
        [ValidateSet('true','false')]
        $compact='false',
        $page,
        [ValidateRange(1,100)]
        $page_size,
        [switch]
        $reverse #switch requested and offered

    )
    if($reverse.IsPresent){
        $temp = @($requested,$offered)
        $offered = $temp[0]
        $requested = $temp[1]
    }
    $uri = -join('https://dexie.space/v1/offers?status=',$status,
    '&requested=',$requested,
    '&requested_min_amount=',$requested_min_amount,
    '&offered=',$offered,
    '&offered_min_amount=',$offered_min_amount,
    '&sort=',$sort,
    '&compact=',$compact,
    '&page=',$page,
    '&page_size=',$page_size)

    $offers = (Invoke-RestMethod -Method Get ([string]$uri)).offers
    
    return $offers

}
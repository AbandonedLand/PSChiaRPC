Start-PodeServer {
   
    $xch_price = (Get-XCHPrice)
    Write-Host -BackgroundColor Red $xch_price
    Add-PodeEndpoint -Address localhost -Port 8000 -Protocol Http
    
    
    Connect-PodeWebSocket -name 'dexie' -Url 'wss://api.dexie.space/v1/stream' -ScriptBlock {
        if(($WsEvent.Request.body | Convertfrom-json).type -eq 'offer'){
            ($WsEvent.Request.body | Convertfrom-json).data | Out-Default
        }
        #$WsEvent.Request | Out-Default
    }
    Add-PodeSchedule -Name 'RunEveryMinute' -Cron '@minutely' -ScriptBlock {
        if(-NOT (Test-PodeWebSocket -Name 'dexie') ){
            Reset-PodeWebSocket -name 'dexie'
        }
        
    }

    Add-PodeSchedule -Name 'xchPrice' -cron '@minutely' -ScriptBlock {
        $xch_price = (Get-XCHPrice)
        Write-Host -BackgroundColor Red $xch_price
    }
    
        
    
}
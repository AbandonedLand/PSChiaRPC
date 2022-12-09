Start-PodeServer {
   
    Set-PodeState -name 'xch_price' -Value (Get-XCHPrice) | Out-Null
    $xch_price = Get-PodeState -Name 'xch_price' 
    Write-Host -BackgroundColor Red -ForegroundColor White 'Current XCH Price :' $xch_price
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
        Set-PodeState -name 'xch_price' -Value (Get-XCHPrice) | Out-Null
        $xch_price = Get-PodeState -Name 'xch_price' 
        Write-Host -BackgroundColor Red -ForegroundColor White 'Current XCH Price :' $xch_price
    }
    
        
    
}
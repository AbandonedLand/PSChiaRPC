Import-PodeModule -Path ./dexie.ps1

Start-PodeServer {
    get-xchprice | out-file xchprice.txt
    Add-PodeTimer -Name "price" -Interval 30 -ScriptBlock {
        get-xchprice | out-file xchprice.txt
        
    }

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

    Add-PodeTimer -name "read" -Interval 5 -ScriptBlock{
        get-content xchprice.txt | Out-default
    }
    
    
        
    
}
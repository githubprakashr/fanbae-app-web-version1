# Test Pusher Beams API with detailed response
$secretKey = "7E6F67C4D2EE4091B3A14ADD7019FA01EC806EDEB800A68DEA99FD6069A4B155"
$instanceId = "de7c2043-6c32-463c-ae56-b8c5d7f40507"

Write-Host "`n[Testing] Pusher Beams API Connection..." -ForegroundColor Cyan
Write-Host "Instance ID: $instanceId" -ForegroundColor Gray
Write-Host "Testing interests: hello, general, debug-hello`n" -ForegroundColor Gray

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $secretKey"
}

# Test different interests
$interests = @("hello", "general", "debug-hello")

foreach ($interest in $interests) {
    Write-Host "[Sending] to interest: $interest" -ForegroundColor Yellow
    
    $body = @{
        interests = @($interest)
        fcm = @{
            notification = @{
                title = "API Test - $interest"
                body = "Testing connection at $(Get-Date -Format 'HH:mm:ss')"
            }
            data = @{
                apptype = "test"
                interest = $interest
                timestamp = (Get-Date).ToString("o")
            }
        }
    } | ConvertTo-Json -Depth 10

    $uri = "https://$instanceId.pushnotifications.pusher.com/publish_api/v1/instances/$instanceId/publishes/interests"

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
        Write-Host "   [SUCCESS] Publish ID: $($response.publishId)" -ForegroundColor Green
    } catch {
        Write-Host "   [FAILED] $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response: $responseBody" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n[Completed] API test finished!`n" -ForegroundColor Cyan

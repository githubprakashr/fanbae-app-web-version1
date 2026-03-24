# Simple notification test
$secretKey = "7E6F67C4D2EE4091B3A14ADD7019FA01EC806EDEB800A68DEA99FD6069A4B155"
$instanceId = "de7c2043-6c32-463c-ae56-b8c5d7f40507"

Write-Host "`nSending test notification to 'hello' interest..." -ForegroundColor Cyan

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $secretKey"
}

$body = @{
    interests = @("hello")
    fcm = @{
        notification = @{
            title = "URGENT TEST"
            body = "Can you see this notification? Reply YES or NO"
        }
        data = @{
            test = "simple"
            timestamp = (Get-Date).ToString()
        }
    }
} | ConvertTo-Json -Depth 10

$uri = "https://$instanceId.pushnotifications.pusher.com/publish_api/v1/instances/$instanceId/publishes/interests"

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
    Write-Host "[SUCCESS] Notification sent! Check your device now." -ForegroundColor Green
    Write-Host "Publish ID: $($response.publishId)" -ForegroundColor Gray
} catch {
    Write-Host "[ERROR] Failed to send: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nIf you don't see the notification:" -ForegroundColor Yellow
Write-Host "1. Make sure the app is running on your device" -ForegroundColor White
Write-Host "2. Check notification permissions are enabled" -ForegroundColor White
Write-Host "3. Try closing and reopening the app" -ForegroundColor White
Write-Host ""

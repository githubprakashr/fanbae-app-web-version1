# Replace YOUR_SECRET_KEY with your actual Pusher Beams Secret Key
$secretKey = "7E6F67C4D2EE4091B3A14ADD7019FA01EC806EDEB800A68DEA99FD6069A4B155"

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $secretKey"
}

$body = @{
    interests = @("hello")
    fcm = @{
        notification = @{
            title = "Test Notification"
            body = "Testing from PowerShell API!"
        }
        data = @{
            title = "Test Notification"
            body = "Testing from PowerShell API!"
            click_action = "FLUTTER_NOTIFICATION_CLICK"
        }
    }
} | ConvertTo-Json -Depth 10

$uri = "https://de7c2043-6c32-463c-ae56-b8c5d7f40507.pushnotifications.pusher.com/publish_api/v1/instances/de7c2043-6c32-463c-ae56-b8c5d7f40507/publishes/interests"

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
    Write-Host "✅ Notification sent successfully!" -ForegroundColor Green
    Write-Host $response
} catch {
    Write-Host "❌ Error sending notification:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

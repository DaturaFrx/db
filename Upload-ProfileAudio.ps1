param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [Parameter(Mandatory=$true)][string]$Token
)

function Send-AudioUploadAttempt {
    param(
        [string]$Label,
        [hashtable]$BodyObject
    )

    Write-Host "`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Trying payload format: $Label"
    $json = $BodyObject | ConvertTo-Json -Depth 3 -Compress

    try {
        $response = Invoke-RestMethod `
            -Uri 'https://api.duolicious.app/profile-info' `
            -Method Patch `
            -Headers @{ Authorization = "Bearer $Token" } `
            -ContentType 'application/json' `
            -Body $json `
            -TimeoutSec 10

        Write-Host "[RESPONSE - $Label]: $response"
    } catch {
        Write-Host "[ERROR - $Label]: $($_.Exception.Message)"
        if ($_.ErrorDetails) {
            Write-Host "[DETAILS]: $($_.ErrorDetails.Message)"
        }
    }
}

Write-Host "[INFO] Starting audio upload script"

if (-Not (Test-Path $FilePath)) {
    Write-Error "File does not exist: $FilePath"
    exit 1
}

Write-Host "[INFO] Reading file: $FilePath"
$bytes = [IO.File]::ReadAllBytes($FilePath)
Write-Host "[INFO] Read $($bytes.Length) bytes. Encoding to Base64..."
$b64 = [Convert]::ToBase64String($bytes)

Send-AudioUploadAttempt -Label "audio" -BodyObject @{ audio = $b64 }
Send-AudioUploadAttempt -Label "audio_base64" -BodyObject @{ audio_base64 = $b64 }
Send-AudioUploadAttempt -Label "base64_audio_file/base64" -BodyObject @{ base64_audio_file = @{ base64 = $b64 } }


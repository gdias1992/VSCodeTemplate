# Get Laravel Log
param (
    [int]$Lines = 100,
    [switch]$Wait
)

$logPath = "$PSScriptRoot\..\backend\storage\logs\laravel.log"

if (Test-Path $logPath) {
    if ($Wait) {
        Write-Host "Tailing Laravel log file (Last $Lines lines)..." -ForegroundColor Cyan
        Get-Content $logPath -Tail $Lines -Wait
    } else {
        Write-Host "Retrieving last $Lines lines from Laravel log file..." -ForegroundColor Cyan
        $content = Get-Content $logPath -Tail $Lines
        if ($null -eq $content) {
            Write-Host "Log file is empty." -ForegroundColor Yellow
        } else {
            $content
        }
    }
} else {
    Write-Host "Log file not found: $logPath" -ForegroundColor Red
}

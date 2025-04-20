# Define which processes to match (add more as needed)
$watchedProcesses = @("eldenring", "rdr2", "cyberpunk2077", "hogwartslegacy")

$coreMask = 0xFFFFFFFE
$handledPIDs = @()

while ($true) {
    $running = Get-Process | Where-Object { $_.Name -in $watchedProcesses -and $_.Id -notin $handledPIDs }

    foreach ($proc in $running) {
        try {
            Write-Host "Detected $($proc.Name) (PID: $($proc.Id)), setting affinity..."
            $proc.ProcessorAffinity = $coreMask
            $handledPIDs += $proc.Id
        } catch {
            Write-Warning "Failed to set affinity for $($proc.Name): $_"
        }
    }

    Start-Sleep -Seconds 2
}

# Define which processes to match (add more as needed)
$watchedProcesses = @("Discord")

$logicalCores = [Environment]::ProcessorCount
$allCoresMask = [math]::Pow(2, $logicalCores) - 1  # e.g. 0xFF for 8 cores
$coreMask = [int]($allCoresMask - 1)              # Disables Core 0 (bit 0)
$handledPIDs = @()

Write-Host "Detected $logicalCores logical cores."
Write-Host "Using affinity mask: $([Convert]::ToString($coreMask, 2).PadLeft($logicalCores, '0'))"

# === MONITOR LOOP ===
while ($true) {
    $running = Get-Process | Where-Object {
        $_.Name -in $watchedProcesses -and $_.Id -notin $handledPIDs
    }

    foreach ($proc in $running) {
        try {
            Write-Host "Setting affinity for $($proc.Name) (PID: $($proc.Id))..."
            $proc.ProcessorAffinity = $coreMask
            $handledPIDs += $proc.Id
        } catch {
            Write-Warning "Failed to set affinity for $($proc.Name): $_"
        }
    }

    Start-Sleep -Seconds 2
}

<#
Restarts a specific service on multiple remote servers and validates its post-restart state.
This script uses WinRM (PowerShell Remoting) to execute service restarts in a robust way,
including error handling and status verification.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ServiceName,

    [Parameter(Mandatory=$true)]
    [string[]]$ComputerNames
)

foreach ($Computer in $ComputerNames) {
    Write-Host "`n[#] Processing Server: $Computer" -ForegroundColor Cyan

    try {
        # Execute the command block on the remote computer
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            param($SvcName)

            # 1. Check if the service exists
            $service = Get-Service -Name $SvcName -ErrorAction Stop

            Write-Host "Action: Restarting service '$SvcName' on $($env:COMPUTERNAME)..."

            # 2. Perform the restart with -Force to handle dependencies
            Restart-Service -Name $SvcName -Force -ErrorAction Stop

            # 3. Wait for the service to initialize (Grace period)
            Start-Sleep -Seconds 5

            # 4. Final Validation
            $finalStatus = (Get-Service -Name $SvcName).Status
            if ($finalStatus -eq "Running") {
                return "SUCCESS: Service '$SvcName' is now UP and Running."
            } else {
                throw "FAILURE: Service '$SvcName' failed to start. Current state: $finalStatus"
            }
        } -ArgumentList $ServiceName -ErrorAction Stop
    }
    catch {
        # Error handling for Network issues, Permissions, or Missing Services
        Write-Host "[-] ERROR on $Computer : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n[*] Execution Task Completed." -ForegroundColor Green
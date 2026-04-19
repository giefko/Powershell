<#

Cleans up temp files for a predefined list of user accounts.
Iterates through an array of usernames and performs file deletion
on their temp folders if files are older than the specified limit.
In combination with task scheduler you can add id as a custom clean up process
#>

# 1. Define the list of accounts to monitor
$AccountList = @("Administrator", "Svc_Backup", "Svc_Automation", "LocalAdmin")

# 2. Configuration parameters
$DaysOld = 7
$SubPath = "AppData\Local\Temp"

Write-Host "--- Starting Bulk Cleanup Task ---" -ForegroundColor Cyan
Write-Host "Targeting files older than $DaysOld days.`n"

foreach ($User in $AccountList) {
    $BasePath = "C:\Users\$User\$SubPath"

    Write-Host "[*] Checking account: $User" -ForegroundColor White

    if (Test-Path $BasePath) {
        try {
            $CutoffDate = (Get-Date).AddDays(-$DaysOld)

            # Identify files to delete
            $FilesToDelete = Get-ChildItem -Path $BasePath -Recurse -File |
                             Where-Object { $_.LastWriteTime -lt $CutoffDate }

            if ($FilesToDelete) {
                $Count = $FilesToDelete.Count
                Write-Host "    -> Found $Count files to remove." -ForegroundColor Yellow

                foreach ($File in $FilesToDelete) {
                    # SilentlyContinue is used because temp files are often 'In Use' (Locked)
                    Remove-Item -Path $File.FullName -Force -ErrorAction SilentlyContinue
                }
                Write-Host "    -> Cleanup for $User completed." -ForegroundColor Green
            }
            else {
                Write-Host "    -> No old files found for this user." -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "    -> Error processing $User: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "    -> Path not found: $BasePath (Skipping...)" -ForegroundColor Red
    }
    Write-Host ("-" * 30)
}

Write-Host "`n[!] Bulk Cleanup Finished." -ForegroundColor Cyan
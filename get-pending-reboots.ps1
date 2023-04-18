# Check a list of servers for pending reboots
# 18APR23

$pendingRebootTests = @(
    @{
        Name = 'RebootPending'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing'  Name 'RebootPending' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'RebootRequired'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'  Name 'RebootRequired' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'PendingFileRenameOperations'
        Test = { Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction Ignore }
        TestType = 'NonNullValue'
    }
)

$serverlist = get-content "c:\temp\servers.txt"

foreach ($server in $serverlist) {
$session = New-PSSession -Computer SRV1
foreach ($test in $pendingRebootTests) {
    $result = Invoke-Command -Session $session -ScriptBlock $test.Test
    if ($test.TestType -eq 'ValueExists' -and $result) {
        $true
    } elseif ($test.TestType -eq 'NonNullValue' -and $result -and $result.($test.Name)) {
        $true
    } else {
        $false
    }
}
$session | Remove-PSSession
}

<#-- Reference
https://4sysops.com/archives/use-powershell-to-test-if-a-windows-server-is-pending-a-reboot/#:~:text=There%20is%20no%20one%20area%20to%20look%20at,one%20or%20more%20servers%20need%20a%20three-finger%20salute.
--#>
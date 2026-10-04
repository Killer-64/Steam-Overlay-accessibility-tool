# Removes the autostart entry, stops the daemon and turns Steam's CEF remote
# debugging back off.
Get-CimInstance Win32_Process -Filter "Name like 'python%'" |
    Where-Object { $_.CommandLine -like '*soa_daemon.py*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Remove-Item (Join-Path ([Environment]::GetFolderPath('Startup')) 'Steam Overlay Access.lnk') -ErrorAction SilentlyContinue

$dirs = @($env:STEAM_DIR,
    (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath,
    (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath)
foreach ($d in $dirs) {
    if ($d) { Remove-Item (Join-Path $d '.cef-enable-remote-debugging') -ErrorAction SilentlyContinue }
}
Write-Host 'Removed. Restart Steam to close its debugging port.'

#Elevates the prompt
param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
# could not elevate, quit
}
 
else {
 
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}

# -----------------------------------------------------------------------------------

Clear-host
Write-Host ".NET 3.5 v1.0.1, updated 5/4/2020

This script installs .NET 3.5 from Microsoft's servers

Created by Richard Bui 3/25/2020" 
pause
Clear-host

Write-Host ".NET 3.5 will now be installed..."
pause
Clear-host

#Saves the current working directory's location
Push-Location
Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 

#Disables the UseWUServer registry key so that the computer can download from Microsoft's servers
Set-ItemProperty . UseWUServer "0" 

#Goes back to the former working directory saved from Push-Location
Pop-Location 
Enable-WindowsOptionalFeature -FeatureName NetFx3

#Re-enables the previous registry key
Push-Location
Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 
Set-ItemProperty . UseWUServer "1" 
Pop-Location 

Write-Host ".NET 3.5 is now installed!"

pause

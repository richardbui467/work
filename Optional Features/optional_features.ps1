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

$b = echo `n 

cls
echo "Optional Feature Script v1.0"
$b
echo "This script allows you to disable a registry key so that you can install optional features from Microsoft's update servers."
$b
echo "Created by Richard Bui 3/25/2020" 
$b
pause
cls


$dotnet = Read-Host "Would you like to install an optional feature? [Y/N]" 

if($dotnet -eq "Y"){

    #Saves the current working directory, goes to the specified registry directory, disables/enables the key, and goes back to the previous working directory
    Push-Location
    Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 
    Set-ItemProperty . UseWUServer "0" 
    Pop-Location 

    #Gets a list of optional features, the online parameter means that the actions are run on the current device
    Get-WindowsOptionalFeature -Online 
    $b
    #This loop continues to ask the user for features until they say "N"
    do{

        #Prompts the user for which feature they want and uses that input to enable the feature
    	$feature = Read-Host "Which feature would you like to install?" 
    	$b
    	Enable-WindowsOptionalFeature -FeatureName $feature -Online -All
	$b
	$again = Read-Host "Would you like to install another feature?"
    $b 

      }until($again -eq "N")

    } 

#Re-enables the previous registry key
Push-Location
Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 
Set-ItemProperty . UseWUServer "1" 
Pop-Location 

pause
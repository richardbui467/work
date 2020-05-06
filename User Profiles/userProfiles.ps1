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

# ---------------------------------------------------------------------------------------------------

Clear-Host
Write-Host "User Profile Script v1.1.3, updated 5/4/2020

Made by Richard Bui 3/5/2020

This script offers a list of user profiles and gives the user the option to delete any

"

pause
Clear-Host

Get-ChildItem "C:\Users`n"
Set-Location "C:\Users"
$profile = Read-Host -Prompt "Would you like to delete any profiles? [Y/N]`n" 

#Continues to ask for profiles to delete until the user says "N"

if ($profile -eq "Y"){
    do{
        
        $del = Read-Host -Prompt "Which profile would you like to delete?`n" 
        Remove-Item $del -Recurse
        Write-Host "$del has been removed!`n"
        Get-ChildItem "C:\Users`n"
        $again = Read-Host -Prompt "Would you like to delete another profile? [Y/N]"
        
    }until($again -eq "N")
}

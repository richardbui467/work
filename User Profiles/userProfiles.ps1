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

$b = echo "`n" 

cls
echo "User Profile Script v1.2"
$b
echo "Made by Richard Bui 3/5/2020"
$b
echo "This script offers a list of user profiles and gives the user the option to delete any"
$b
pause
cls

#Shows the user a list of the user profiles and asks if they want to delete any
#Switches to the "Users" directory otherwise the script will still be inside the logged in user's directory and will fail
#If they say "Y", then they input the name of the user profile and it is deleted

dir "C:\Users"
$b
cd "C:\Users"
$profile = Read-Host -Prompt "Would you like to delete any profiles? [Y/N]" 

#If the user hits "Y", then a loop will run. The loop asks the user for which profile they want to delete. 
#After the user provides input, the shell will say that the profile has been removed and will bring up another listing of the user profiles.
#Then the script will ask the user if they want to delete another. If they input "Y", the user will be asked for which profile to delete again.
#This loop will keep running UNTIL the user inputs "N", which ends the script.

if ($profile -eq "Y"){
    do{
        $b
        $del = Read-Host -Prompt "Which profile would you like to delete?" 
        Remove-Item $del -Recurse
        $b
        echo "$del has been removed!"
        $b
        dir "C:\Users"
        $b
        $again = Read-Host -Prompt "Would you like to delete another profile? [Y/N]"
    }until($again = "N")
}

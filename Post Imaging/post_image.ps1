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

$b = echo "`n" 

cls
echo "Post-Imaging Script v. 0.5.0" 
$b
echo "This script automates several procedures of the post-imaging process" 
$b
echo "Made by Richard Bui 3/23/2020"
$b 
pause
cls

Write-Host "You can perform the following `n`n1.) Windows updates `n`n2.) BIOS updates
`n3.) Make the client a local admin `n`n4.) Install Cisco AnyConnect VPN `n`n5.) Check and install software 
`n6.) Enable optional features "
$b
$action = Read-Host "Which action would you like to perform?"
$action.ToString()
cls


if($action -eq "1"){ 

    #This checks for the PSWindowsUpdate module, if it is there then the script will go ahead and check for updates
    #If the module is not there, then the script will install the module first

    if(Get-InstalledModule -Name "PSWindowsUpdate"){

    	Get-WindowsUpdate 
	$b
    	$update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	if($update -eq "Y"){ 
    
        	Install-WindowsUpdate

        	}

	}else{
	
	    echo "In order to install Windows Updates, a module must be imported" 
    	$b
    	pause
    	cls
    	Install-Module "PSWindowsUpdate"
    	Get-WindowsUpdate 
    	$update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	if($update -eq "Y"){ 
    
            #Installs and accepts all the updates automatically and logs it
        	Install-WindowsUpdate -AcceptAll  | Out-File "C:\logs\$(get-date -f yyyy-MM-dd) -WindowsUpdate.log" -force 

        	}
	}
}

if($action -eq "2"){ 

    #The current working directory is printed out so that it can be used to locate the installers
    #The installers for Dell Command Update and HP Support assistant will come with the script and the script will install either depending on input
    #This method will likely not be kept since it is kind of inefficient

    $pwd = pwd
    $man = Read-Host "Is this a Dell computer or HP computer?" 
    $man.ToLower() 

    if($man -eq "dell"){ 

        echo "Dell Command Update will be installed now."
        pause
        cls
        Start-Process "$pwd\Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.exe"

        }

    if($man -eq "hp"){
        
        echo "HP Support Assistant will be installed now."
        $b
        pause
        cls
        Start-Process "$pwd\sp101214.exe" 

        }

}

if($action -eq "3"){ 

    #Asks the user for an AD account, adds it to the local admin group, and prints out the local admin group for confirmation

    $user = Read-Host "Who would you like to add to the local administrators group? Please enter in the Active Directory account name"

    Add-LocalGroupMember -Group "Administrators" -Member $user 

    Get-LocalGroupMember -Group "Administrators"
    
    }

if($action -eq "4"){

    #Retrieves the VPN installer from Aquarius and installs it

    echo "Cisco AnyConnect will be installed now."
    $b
    pause
    cls
    Start-Process "\\cob-aquarius\B$\Install\PC\Cisco AnyConnect\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe"

    }

if($action -eq "5"){}

if($action -eq "6"){} 

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

# -------------------------------------------------------------------------------------------------------------------

<#  // INTRODUCTION // 

        This script aims to automate the post-imaging process entirely by running through the common procedures of 
    post-imaging such as windows updates, BIOS updates, etc. 

        How this script works is that the end user checks off a list of all the functions available listed below 
    that tells the script to perform all of these desired tasks. 
    
    // FUNCTIONS //

     Update-Windows - Downloads and installs Windows Updates

     Update-BIOS - Downloads the installer for either HP Support Assistant or Dell Command Update and installs either

     Set-LocalAdmin - Allows the end user to input the user account of the customer to make them a local admin
     so that they can install what they want on the machine

     Install-VPN - Downloads and installs Cisco AnyConnect silently 

     Install-NET - Enables the optional feature for .NET 3.5 

     Install-Software - Installs lab software if needed 

     Invoke-Script - This function just calls upon all the other functions 

#>

$install_drive = "\\cob-aquarius\B$\Install\PC\"

$modules = @("PSWindowsUpdate")

#Used in the following functions: Install-Software, Invoke-Script
$lab_software_list = @("Anaconda, Power BI")

Write-Host "Post Imaging, Richard Bui, 5/5/2020

    This script aims to automate the post-imaging process entirely by running through the common procedures of 
post-imaging such as windows updates, BIOS updates, etc. 

    How this script works is that the end user checks off a list of all the functions available listed below 
that tells the script to perform all of these desired tasks. 

    This script will begin by installing the necessary modules in order to proceed: $modules

"
pause

foreach ($i in $modules){
    
    Install-Module $i
    Import-Module $i 

}

function Update-Windows{

    Start-Job -ScriptBlock { Get-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall }
    Write-Host "Windows is now downloading and installing updates..."
    $job_status = Get-Job | Select-Object -Property State 
    if($job_status -eq "Completed"){

        Write-Host "Windows has finished installing updates. A restart is required. Note that there may be more updates that come afterwards."

    }

} 

function Update-BIOS{

    #? 

}

function Set-LocalAdmin{

    while(true){
    
        $user = Read-Host "Please enter in the customer's AD account: `n"
    
        $user_confirm = Read-Host "Are you sure you want $user to become the local administrator? [Y/N]`n"
    
        if($user_confirm -eq "Y"){

            Add-LocalGroupMember -Group "Administrators" -Member $user 
            Get-LocalGroupMember -Group "Administrators"
            break

        }

    }

}

function Install-VPN{

    Copy-Item "$install_drive\Cisco AnyConnect\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe" "$env:USERPROFILE\Desktop"
    Start-Process -FilePath "$env:USERPROFILE\Desktop\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe" -ArgumentList "/passive"
    Write-Host "Cisco AnyConnect is installing..."
    
}

function Install-NET{

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

    Write-Host ".NET 3.5 has been enabled."

}

function Install-Software{

    Copy-Item "$install_drive\Anaconda\Anaconda3-2019.10-Windows-x86_64 (1).exe" "$env:USERPROFILE\Desktop"
    Copy-Item "$install_drive\Power BI\PBIDesktop_x64.msi" "$env:USERPROFILE\Desktop"
    Start-Process -FilePath "$env:USERPROFILE\Desktop\Anaconda3-2019.10-Windows-x86_64 (1).exe" -ArgumentList "/passive"
    Start-Process -FilePath "$env:USERPROFILE\Desktop\PBIDesktop_x64.msi" -ArgumentList "/passive"

    Write-Host "The following software is currently being installed - $lab_software_list"

}

function Invoke-Script{

    $option_list = @("1.) Windows updates", 
    "2.) BIOS updates", 
    "3.) The customer will be set as the local admin", 
    "4.) Cisco AnyConnect will be installed", 
    "5.) .NET 3.5 will be enabled",
    "6.)  Installing lab software - $lab_software_list"
    )

    Write-Host "The following tasks will be performed:
    
$option_list
    
"
    $updates = Read-Host "If you are looking to only install Windows updates, press 1. Otherwise, all processes will be started."
    if($updates -eq "1"){

        Update-Windows

    }else{    
        
        Update-Windows
        Update-BIOS
        Set-LocalAdmin
        Install-VPN
        Install-NET
    
    }
    
}

Invoke-Script
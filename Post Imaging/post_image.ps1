﻿param([switch]$Elevated)
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
echo "Post-Imaging Script v. 0.6" 
$b
echo "This script automates several procedures of the post-imaging process" 
$b
echo "Made by Richard Bui 3/23/2020"
$b 
pause
cls

Write-Host "You can perform the following `n`n1.) Windows updates `n`n2.) BIOS updates
`n3.) Make the client a local admin `n`n4.) Install Cisco AnyConnect VPN `n`n5.) Install software"
$b
$action = Read-Host "Which action would you like to perform?"
$action.ToString()
cls


if($action -eq "1"){ 

    #This checks for the PSWindowsUpdate module, if it is there then the script will go ahead and check for updates
    #If the module is not there, then the script will install the module first

    if(Get-InstalledModule -Name "PSWindowsUpdate"){

        cls
    	Get-WindowsUpdate 
	    $b
    	$update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	if($update -eq "Y"){ 
    
            #Installs and accepts all the updates automatically
        	Install-WindowsUpdate -AcceptAll 

        	}

	}else{
	
        cls
	    echo "In order to install Windows Updates, a module must be imported" 
    	$b
    	pause
    	cls
    	Install-Module "PSWindowsUpdate"
        Read-Host "The module has been installed. Press enter to receive a list of updates."
        cls
    	Get-WindowsUpdate 
        $b
    	$update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	if($update -eq "Y"){ 
    
        	Install-WindowsUpdate -AcceptAll 

        	}
	}
}

$rootpath = "\\cob-aquarius\B$\Install\PC"
$destination = "$env:USERPROFILE\Downloads"

if($action -eq "2"){ 

    $pwd = pwd
    $man = Read-Host "Is this a Dell computer or HP computer?" 
    $man.ToLower() 

    if($man -eq "dell"){ 

        echo "Dell Command Update will be installed now."
        pause
        cls
        Write-Progress -Activity "Downloading Dell Command Update installer..." 
        Start-BitsTransfer -Source "https://dl.dell.com/FOLDER06095696M/1/Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.EXE" -Destination "$env:USERPROFILE\Downloads"
        Write-Progress -Activity "Installing Dell Command Update..."
        Start-Process "$destination\Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.exe" -ArgumentList /qn
        echo "Dell Command Update has been installed!"

        }

    if($man -eq "hp"){ 
        
        echo "HP Support Assistant will be installed now."
        $b
        pause
        cls
        Copy-Item "$pwd\HP\sp101214.exe" -Destination $destination 
        Write-Progress -Activity "Installing HP Support Assistant..." 
        Start-Process "$destination\sp101214.exe" -ArgumentList /qn
        echo "HP Support Assistant has been installed!"

        }
}

if($action -eq "3"){ 

    #Asks the user for an AD account, adds it to the local admin group, and prints out the local admin group for confirmation

    $user = Read-Host "Who would you like to add to the local administrators group? Please enter in the Active Directory account name"

    $confirm = Read-Host "Are you sure you want to add $user to the local administrator's group? [Y/N]"

    if($confirm -eq "Y"){

        Add-LocalGroupMember -Group "Administrators" -Member $user 

        Get-LocalGroupMember -Group "Administrators"

        }     
    }

if($action -eq "4"){
      
    cls
    echo "1.) Anaconda `n`n2.) .NET 3.5 `n`n3.) SAS `n`n4.) MySQL `n`n5.) Prophet `n`n6.) Microsoft Power BI `
    `n7.) Cisco AnyConnect"
    $b
    $choice = Read-Host "Which software would you like to install? Please enter in the full name"
    $software = $choice

    function install{

        param(
        
            [string]$DestinationPath, 
            [string]$ProgramName,
            [string]$ProgramPath,
            [string]$Installer

            )

        echo "$ProgramName will now be installed."
        $b
        pause
        cls
        Copy-Item -Path $ProgramPath -Destination "$DestinationPath"
        $install = Read-Host "Would you like the installation to be silent? [Y/N]"
    
        if($install -eq "Y"){ 

            Write-Progress -Activity "$ProgramName is now being installed..." 
            Start-Process -FilePath "$DestinationPath\$Installer" -ArgumentList /qn 
            echo "$ProgramName is now installed!" 
        
            }else{

                Write-Progress -Activity "$ProgramName is now being installed..." 
                Start-Process -FilePath "$DestinationPath\$Installer" 
                echo "$ProgramName is now installed!" 
            
            }
        }

    function installparam{

        install -DestinationPath $destination -ProgramName $software -ProgramPath $programPath -Installer $exe 

        }

    function dotnet{

        echo ".NET 3.5 will now be installed..."
        $b
        pause
        cls
        Push-Location
        Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 
        Set-ItemProperty . UseWUServer "0" 
        Pop-Location 

        Enable-WindowsOptionalFeature -FeatureName $feature -Online -All

        Push-Location
        Set-Location HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU 
        Set-ItemProperty . UseWUServer "1" 
        Pop-Location 
        echo ".NET 3.5 is now installed!"

        }

    function prereq{

        param(

            [string]$programName,
            [string]$preProgramName,
            [string]$preProgramPath,
            [string]$preDestinationPath,
            [string]$preInstaller

            )

        if("$preProgramPath" -eq $true){

            echo "$preProgramName is installed on the computer. The installation of $programName will proceed."
            installparam

                }else{

                    echo "$preProgramName is not installed on the computer. This will be installed first."
                    Copy-Item $preProgramPath -Destination $destination
                    Write-Process -Activity "Installing $preProgramName..."
                    Start-Process $destination\$preInstaller -ArgumentList /qn -Wait
                    installparam

                }
         }
                  

    function prereqparam{

        prereq -preProgramName $preName -preProgramPath $prePath -preInstaller $preExe -preDestinationPath $destination
   
        }

    if($software -eq "Anaconda"){

        $programPath = "$rootpath\Anaconda\Anaconda3-2019.10-Windows-x86_64 (1).exe"
        $exe = "Anaconda3-2019.10-Windows-x86_64 (1).exe"

        installparam

        }

    if($software -eq ".NET 3.5"){

        dotnet

        }

    if($software -eq "SAS"){

        $programPath = "\\statsrv\SAS\SAS 9.4\SAS 9.4 TS1M2\setup.exe"
        $exe = "setup.exe"

        if("C:\Windows\Microsoft.NET\Framework64\v3.5\" -eq $true){

            echo ".NET 3.5 is installed on the computer. The installation of SAS will proceed."
            installparam

            }else{ 
                
                echo ".NET 3.5 is not installed on the computer. This will be installed first."
                $b
                pause
                dotnet
                $b
                pause
                $b
                installparam
                
                }   
    }

    if($software -eq "MySQL"){

        $programPath = "$rootpath\MySQL Community Server\Current2020\[USE THIS ONE] mysql-installer-community-8.0.19.0.msi"
        $exe = "[USE THIS ONE] mysql-installer-community-8.0.19.0.msi"
        $preProgramPath = "$env:ProgramFiles(x86)\Microsoft Visual Studio 14.0"
        $preName = "Visual Studio 2015" 
        $preExe = "vs_professional__7c37f2f3d6c2a642899d97a8291bd3a7.exe"

        prereqparam
    }

    if($software -eq "Prophet"){

        $programName = "Prophet"
        $programPath = "$rootpath\Prophet\Install Second - Prophet Professional\PP 9.0.4\PP 9.0.4\Setup.exe"
        $exe = "Setup.exe"
        $preProgramPath = "$env:ProgramFiles(x86)\Microsoft Visual Studio 12.0"
        $preName = "Visual Studio 2013"
        $preExe = "wdexpress_full.exe"

        prereqparam

    if($software -eq "Microsoft Power BI"){

        $programPath = "$rootpath\Power BI\PBIDesktop_x64.msi"
        $exe = "PBIDesktop_x64.msi"

        installparam

        }

    if($software -eq "Cisco AnyConnect"){

        $programPath = "$rootpath\Cisco AnyConnect\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe"
        $exe = "anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe"

        installparam
    }
}


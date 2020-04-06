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

## VARIABLES ##

$rootpath = "\\cob-aquarius\B$\Install\PC"
$destination = "$env:USERPROFILE\Downloads"

## FUNCTIONS ##

function Windows{

    #This checks for the PSWindowsUpdate module, if it is there then the script will go ahead and check for updates
    #If the module is not there, then the script will install the module first

    if(Get-InstalledModule -Name "PSWindowsUpdate"){

        cls
    	Get-WindowsUpdate 
    	$update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	if($update -eq "Y"){ 
    
            #Installs and accepts all the updates automatically
        	Install-WindowsUpdate -AcceptAll 
            pause
            cls

        	}

	    }else{
	
            cls
	        Write-Host "In order to install Windows Updates, a module must be imported" 
    	    pause
    	    cls
    	    Install-Module "PSWindowsUpdate"
            Read-Host "The module has been installed. Press enter to receive a list of updates."
            cls
    	    Get-WindowsUpdate 
    	    $update = Read-Host "Would you like to install the following updates? [Y/N]" 
   
    	    if($update -eq "Y"){ 
    
            	Install-WindowsUpdate -AcceptAll
                pause
                cls

            	}
	        }
}

function BIOS{

    #Prints the current working directory so that the HP installer can be called to without making a hard-coded path
    $pwd = pwd
    #Asks the user if they have a Dell or HP so that the right tool can be installed. 
    #The input is converted to a lowercase string so that capitalization differences can be accounted for.
    $man = Read-Host "Is this a Dell computer or HP computer?" 
    $man.ToLower() 
    
    if($man -eq "dell"){ 
    
        #Downloads the Dell Command Update installer from Dell's servers to the user's Downloads folder and starts installing it silently afterwards
        Write-Host "Dell Command Update will be installed now."
        pause
        cls
        Write-Progress -Activity "Downloading Dell Command Update installer..." 
        Start-BitsTransfer -Source "https://dl.dell.com/FOLDER06095696M/1/Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.EXE" -Destination "$env:USERPROFILE\Downloads"
        Write-Progress -Activity "Installing Dell Command Update..."
        Start-Process "$destination\Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.exe" -ArgumentList /qn
        Write-Host "Dell Command Update has been installed!"
        pause
        cls
    
        }
    
    if($man -eq "hp"){ 
        
        #Just copies the HP Support Assistant installer to the Downloads folder and installs it from there since I couldn't find it online
        Write-Host "HP Support Assistant will be installed now."
        pause
        cls
        Copy-Item "$pwd\HP\sp101214.exe" -Destination $destination 
        Write-Progress -Activity "Installing HP Support Assistant..." 
        Start-Process "$destination\sp101214.exe" -ArgumentList /qn
        Write-Host "HP Support Assistant has been installed!"
        pause
        cls
    
        }
}

function Admin{

    #Asks the user for an AD account, adds it to the local admin group, and prints out the local admin group for confirmation
    
    $user = Read-Host "Who would you like to add to the local administrators group? Please enter in the Active Directory account name"
    $confirm = Read-Host "Are you sure you want to add $user to the local administrator's group? [Y/N]"
    
    if($confirm -eq "Y"){
    
        Add-LocalGroupMember -Group "Administrators" -Member $user 
        Get-LocalGroupMember -Group "Administrators"
        pause
        cls

        }     
    }

function Software{

    cls
    
    function Library{

        $choice = Read-Host "1.) Anaconda 
2.) .NET 3.5 
3.) SAS 
4.) MySQL 
5.) Prophet 
6.) Microsoft Power BI `
7.) Cisco AnyConnect
        
Which software would you like to install? Please enter in the full name"
        $software = $choice
    
    }

    function InstallOther{

        $othersoftware = Read-Host "Would you like to install another piece of software? [Y/N]" 

        if($othersoftware -eq "Y"){
        
            Library

        }else{

        Actions
        
        }
    }
    
    function install{
    
        param(
        
            [string]$DestinationPath, 
            [string]$ProgramName,
            [string]$ProgramPath,
            [string]$Installer
    
            )
    
        Write-Host "$ProgramName will now be installed."
        pause
        cls
        Copy-Item -Path $ProgramPath -Destination "$DestinationPath"
        $install = Read-Host "Would you like the installation to be silent? [Y/N]"
    
        if($install -eq "Y"){ 
    
            Write-Progress -Activity "$ProgramName is now being installed..." 
            Start-Process -FilePath "$DestinationPath\$Installer" -ArgumentList /qn 
            Write-Host "$ProgramName is now installed!"
        
            }else{
    
                Write-Progress -Activity "$ProgramName is now being installed..." 
                Start-Process -FilePath "$DestinationPath\$Installer" 
                Write-Host "$ProgramName is now installed!"
            
                }
        }
    
    function installparam{
    
        install -DestinationPath $destination -ProgramName $software -ProgramPath $programPath -Installer $exe 
    
        }
    
    function dotnet{
    
        Write-Host ".NET 3.5 will now be installed..."
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
        Write-Host ".NET 3.5 is now installed!"
    
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
    
            Write-Host "$preProgramName is installed on the computer. The installation of $programName will proceed."
            installparam
            InstallOther
    
                }else{
    
                    Write-Host "$preProgramName is not installed on the computer. This will be installed first."
                    Copy-Item $preProgramPath -Destination $destination
                    Write-Process -Activity "Installing $preProgramName..."
                    Start-Process $destination\$preInstaller -ArgumentList /qn -Wait
                    installparam
                    InstallOther
    
                    }
         }
                  
    function prereqparam{
    
        prereq -preProgramName $preName -preProgramPath $prePath -preInstaller $preExe -preDestinationPath $destination
    
        }

    Library
    
    if($software -eq "Anaconda"){
    
        $programPath = "$rootpath\Anaconda\Anaconda3-2019.10-Windows-x86_64 (1).exe"
        $exe = "Anaconda3-2019.10-Windows-x86_64 (1).exe"
    
        installparam
        InstallOther
    
        }
    
    if($software -eq ".NET 3.5"){
    
        dotnet
        Installother
    
        }
    
    if($software -eq "SAS"){
    
        $programPath = "\\statsrv\SAS\SAS 9.4\SAS 9.4 TS1M2\setup.exe"
        $exe = "setup.exe"
    
        if("C:\Windows\Microsoft.NET\Framework64\v3.5\" -eq $true){
    
            Write-Host ".NET 3.5 is installed on the computer. The installation of SAS will proceed."
            installparam
            InstallOther
    
            }else{ 
                
                Write-Host ".NET 3.5 is not installed on the computer. This will be installed first."
                pause
                dotnet
                pause
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
    
        }
    
    if($software -eq "Microsoft Power BI"){
    
        $programPath = "$rootpath\Power BI\PBIDesktop_x64.msi"
        $exe = "PBIDesktop_x64.msi"
    
        installparam
        InstallOther
    
        }
    
    if($software -eq "Cisco AnyConnect"){
    
        $programPath = "$rootpath\Cisco AnyConnect\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe"
        $exe = "anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe"
    
        installparam
        InstallOther

        }
    
    }

Write-Host "Post-Imaging Script v. 0.6.5

This script automates several procedures of the post-imaging process

Made by Richard Bui 3/23/2020"

pause
cls

    $action = Read-Host  "You can perform the following 
    
1.) Windows updates 
2.) BIOS updates
3.) Make the client a local admin 
4.) Install software


Which action would you like to perform?"

    cls

    if($action -eq "1"){ 

        Windows

        }

    if($action -eq "2"){

        BIOS

        }

    if($action -eq "3"){

        Admin 

        }

    if($action -eq "4"){ 

        Software

        }


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
echo "Post-Imaging Script v. 0.7.0" 
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
        Write-Progress -Activity "Downloading Dell Command Update installer..." 
        Start-BitsTransfer -Source "https://dl.dell.com/FOLDER06095696M/1/Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.EXE" -Destination "$env:USERPROFILE\Downloads"
        Write-Progress -Activity "Installing Dell Command Update..."
        Start-Process "$env:USERPROFILE\Downloads\Dell-Command-Update-Win-32_PH01C_WIN_3.1.1_A00.exe" -ArgumentList /qn
        echo "Dell Command Update has been installed!"

        }

    if($man -eq "hp"){ 
        
        echo "HP Support Assistant will be installed now."
        $b
        pause
        cls
        Write-Progress -Activity "Downloading HP Support Assistant installer..."
        Start-BitsTransfer -Source "javascript:void(0)"
        Write-Progress -Activity "Installing HP Support Assistant..." 
        Start-Process "$pwd\sp101214.exe" -ArgumentList /qn
        echo "HP Support Assistant has been installed!"

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
    Write-Progress -Activity "The Cisco AnyConnect installer is being copied from \\cob-aquarius\B$\Install\PC\Cisco AnyConnect\ to the Downloads folder..." 
    Copy-Item -Path "\\cob-aquarius\B$\Install\PC\Cisco AnyConnect\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe" -Destination "$env:USERPROFILE\Desktop"
    Write-Progress -Activity "Installing Cisco AnyConnect..."
    Start-Process -FilePath "$env:USERPROFILE\Desktop\anyconnect-win-4.7.04056-core-vpn-webdeploy-k9.exe" -ArgumentList /qn
    echo "Cisco AnyConnect has been installed!" 

    }

if($action -eq "5"){

    $software = Read-Host "Your options are: `n`n1.) Check for software `n`n2.) Install software" 

    if($software = 1){}

    if($software = 2){
        
            echo "1.) Anaconda `n.2.) .NET 3.5 `n3.) SAS `n4.) MySQL `n5.) Prophet `n6.) Microsoft Power BI"
            $b
            $choice = Read-Host "Which software would you like to install? Please choose a number."
   
            function Get-Installer{
            
                $program = "$choice"
                $rootpath = "\\cob-aquarius\B$\Install\PC"
                $destination = "$env:USERPROFILE\Downloads"
                
                if($program -eq "Anaconda"){

                    $programPath = "$rootpath\Anaconda\Anaconda3-2019.10-Windows-x86_64 (1).exe"
                    $exe = "Anaconda3-2019.10-Windows-x86_64 (1).exe"

                    }

                if($program -eq "Microsoft Power BI"){

                    $programPath = "$rootpath\Power BI\PBIDesktop_x64.msi"
                    $exe = "PBIDesktop_x64.msi"

                    }

                if($program -eq "SAS"){

                    $programPath = "\\statsrv\SAS\SAS 9.4\SAS 9.4 TS1M2\setup.exe"
                    $exe = "setup.exe"

                    Push-Location
                    Set-Location "HKLM\Software\Microsoft\NET Framework Setup\NDP\v3. 5\Install"
                    Get-ItemProperty . Install
                    

                    }

                if($program -eq "MySQL"){

                    $programPath = "$rootpath\MySQL Community Server\Current2020\[USE THIS ONE] mysql-installer-community-8.0.19.0.msi"
                    $exe = "[USE THIS ONE] mysql-installer-community-8.0.19.0.msi"

                    if("$env:ProgramFiles(x86)\Microsoft Visual Studio 14.0" -eq $true){

                    echo "Visual Studio 2015 is installed on the computer."

                        }else{

                        echo "Visual Studio 2015 is not installed on the computer. This will be installed first."
                        Copy-Item "$rootpath\Microsoft Visual Studio\Microsoft Visual Studio 2015\vs_professional__7c37f2f3d6c2a642899d97a8291bd3a7.exe" -Destination $destination
                        Write-Process -Activity "Installing Visual Studio 2015..."
                        Start-Process $destination\$exe -ArgumentList /qn

                        }

                    }

                if($program -eq "Prophet"){

                    $programPath = "$rootpath\Prophet\Install Second - Prophet Professional\PP 9.0.4\PP 9.0.4\Setup.exe"
                    $exe = "Setup.exe"

                    if("$env:ProgramFiles(x86)\Microsoft Visual Studio 12.0" -eq $true){

                        echo "Visual Studio 2013 is installed on the computer."

                        }else{

                            echo "Visual Studio 2013 is not installed on the computer. This will be installed first."
                            Copy-Item "$rootpath\Prophet\Install First - Visual Studio 2013 Express Edition\wdexpress_full.exe" -Destination $destination
                            Write-Progress -Activity "Installing Visual Studio 2013..."
                            Start-Process "$destination\wdexpress_full.exe" -ArgumentList /qn 
                        
                    }

                echo "$program will now be installed..."
                $b
                pause
                cls
                Copy-Item -Path $programPath -Destination "$destination"
                $install = Read-Host "Would you like the installation to be silent? [Y/N]"
             
                if($install -eq "Y"){ 

                    Write-Progress -Activity "$program is now being installed..." 
                    Start-Process -FilePath "$destination\$exe" -ArgumentList /qn
                    echo "$program is now installed!" 
                
                }else{

                    Write-Progress -Activity "$program is now being installed..." 
                    Start-Process -FilePath "$destination\$exe" 
                    echo "$program is now installed!" 
                    
                    }
            
            }

            if($choice -eq "2"){

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

                }else{

                    Get-Installer 

                }

        }
    }
}

if($action -eq "6"){

    $dotnet = Read-Host "Would you like to enable an optional feature? [Y/N]" 
    
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
    
} 

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

Clear-Host 
Write-Host "AD Users and Computers v1.0.1, updated 5/4/2020
            
This script allows you to create users and computers within Active Directory

Made by Richard Bui 3/23/2020

"

pause
Clear-Host

# FUNCTIONS 

    # New Object - Creates a computer object
    # Edit-Object - Edits a computer object's description
    # Move-Object - Moves a computer object from one distinguished path to another
    # Enable-Account - Enables/disables a user account
    # Drive Access - Drives are granted depending on which groups the user are in. This just adds/removes users from groups.

function New-Object{

    do{

        $name = Read-Host "Enter name"
        $description = Read-Host "Enter description"
        $path = Read-Host "Enter the OU path"

        New-ADComputer -Name $name -Description $description -Path "$path,DC=TEST,DC=DOMAIN" -Confirm

        "`n"
        $again = Read-Host "Would you like to create another? [Y/N]"
        Clear-Host

        }until($again -eq "N") 

    }

function Edit-Object{

    do{

        Get-ADComputer -Filter * | Select-Object Name | Format-Table 
        $computer = Read-Host "Which computer would you like to edit?"
        "`n"
        $desc = Read-Host "Enter new description" 

        Set-ADComputer -Identity $computer -Description $desc

        "`n" 
        $again = Read-Host "Would you like to edit another computer's description? [Y/N]" 
        $again.ToUpper()
        Clear-Host

        }until($again -eq "N")

    }

function Move-Object{

    do{

        Get-ADComputer -Filter * | Select-Object DistinguishedName | Format-Table
        $identity = Read-Host "Please enter the distinguished name of the object to move"
        "`n"
        $destination = Read-Host "Please enter in the destination OU of the object"

        Move-ADObject -Identity $identity -TargetPath "$destination,DC=TEST,DC=DOMAIN" -Confirm

        "`n"
        $again = Read-Host "Would you like to move another computer? [Y/N]" 
        $again.ToUpper()

        }until($again -eq "N")

    }
    
function Enable-Account{

    $enable = Read-Host "Press 1 to enable or press 0 to disable the account"
    "`n" 
    if($enable-eq "1"){
    
        Enable-ADAccount -Identity $user
        Write-Host "$user has been enabled"
        "`n" 
        Get-ADUser -Identity $user | Select-Object Enabled | Format-Table
        "`n" 
        pause
        Clear-Host

    }else{
    
        Disable-ADAccount -Identity $user
        Write-Host "$user has been disabled" 
        "`n" 
        Get-ADUser -Identity $user | Select-Object Enabled | Format-Table
        "`n" 
        pause
        Clear-Host
    
        }

    }

function Drive-Access{ 

    Write-Host "In order to grant/remove drive access, the user must be added(+)/removed(-) to or from a group" 
    "`n"  
    $access = Read-Host "Would you like to add or remove drive access? [+/-]"
    "`n"
    if($access -eq "+"){

        do{

            Get-ADGroup -Filter * | Select-Object name | Sort-Object | Format-Table
            $groups = Read-Host "Which groups would you like to give access to $user?" 
            Add-ADGroupMember -Identity $groups -Members $user
            "`n"
            $again = Read-Host "Would you like to add another? [Y/N]"

            }until($again -eq "N")
            

        }else{
    
        do{

            Get-ADGroup -Filter * | Select-Object name | Sort-Object | Format-Table
            $groups = Read-Host "Which groups would you like to remove $user from?" 
            Remove-ADGroupMember -Identity $groups -Members $user
            "`n"
            $again = Read-Host "Would you like to add another? [Y/N]"

            }until($again -eq "N")

        }

    }
  
function Main{

    $choice = Read-Host "Would you like to manage a user or manage a computer?"
    $choice.ToLower()
    Clear-Host
    
    if($choice -eq "user"){
    
            while($true){ 
    
                Get-ADUser -Filter * | Select-Object SamAccountName | Format-Table 
    
                $user = Read-Host "Which user would you like to manage? If there is no user you would like to manage then press 'q' to quit. If you want to configure something else press 'c'" 

                if($user -eq "q"){
                
                    exit
                
                }

                if($user -eq "c"){
                
                    "`n"
                    Main
                
                }
    
                Clear-Host
                $action = Read-Host "Here are a list of choices: 
                
1.) Grant/remove drive access  
2.) Enable/disable a user
3.) Configure something else

What would you like to do with '$user'?"
    
                Clear-Host
    
                if($action -eq "1"){
                
                    Drive-Access
    
                    }
    
                if($action -eq "2"){
                 
                    Enable-Account
    
                    }

                if($action -eq "3"){
                
                    Main
                
                    }
    
                }
    
            }
    
    if($choice -eq "computer"){
       
       while($true){
    
            Write-Host "Here are your list of choices: 
            
1.) Create a new object 
2.) Edit an object's description 
3.) Move an object
4.) Quit
5.) Configure something else

"
            $action = Read-Host "What would you like to do?" 
            Clear-Host
        
            if($action -eq "1"){
                
                New-Object
        
                }
        
            if($action -eq "2"){
        
                Edit-Object
          
                }
        
            if($action -eq "3"){
        
                 Move-Object
        
                }
    
            if($action -eq "4"){
            
                exit
            
                }

            if($action -eq "5"){
            
                Main

                }
            }
        }
    }

Main
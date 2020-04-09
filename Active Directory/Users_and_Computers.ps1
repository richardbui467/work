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

Import-Module "activedirectory"

cls 
Write-Host "AD Users and Computers v1.0" 
"`n"
Write-Host "This script allows you to create users and computers within Active Directory"
"`n"
Write-Host "Made by Richard Bui 3/23/2020"
"`n"
pause
cls

## FUNCTIONS ## 

function New-Object{

    do{

#Receives inputs from the user so that those inputs can be used to create the computer object

        $name = Read-Host "Enter name"
        $description = Read-Host "Enter description"
        $path = Read-Host "Enter the OU path"

        New-ADComputer -Name $name -Description $description -Path "$path,DC=TEST,DC=DOMAIN" -Confirm

        "`n"
        $again = Read-Host "Would you like to create another? [Y/N]"
        cls

        }until($again -eq "N") 
    }

function Edit-Object{

    do{

#Shows a list of all computer objects available and asks the user for a computer and a new description which are stored in values to be used

        Get-ADComputer -Filter * | select Name | Format-Table 
        $computer = Read-Host "Which computer would you like to edit?"
        "`n"
        $desc = Read-Host "Enter new description" 

        Set-ADComputer -Identity $computer -Description $desc

        "`n" 
        $again = Read-Host "Would you like to edit another computer's description? [Y/N]" 
        $again.ToUpper()
        cls

        }until($again -eq "N")
    }

function Move-Object{

    do{

#Shows a list of all computer objects and filters them by their distinguished name (which is the one of the only two viable inputs for moving computer objects)
#The user selects a distinguished name and then inputs the destination OU so that the computer can be moved to that destination 

        Get-ADComputer -Filter * | select DistinguishedName | Format-Table
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

#After the end user selects a user, they can either enable or disable it. Either way, the computer returns the "Enabled" value of the user to confirm the action

    $enable = Read-Host "Press 1 to enable or press 0 to disable the account"
    "`n" 
    if($enable-eq "1"){
    
        Enable-ADAccount -Identity $user
        Write-Host "$user has been enabled"
        "`n" 
        Get-ADUser -Identity $user | select Enabled | Format-Table
        "`n" 
        pause
        cls

    }else{
    
        Disable-ADAccount -Identity $user
        Write-Host "$user has been disabled" 
        "`n" 
        Get-ADUser -Identity $user | select Enabled | Format-Table
        "`n" 
        pause
        cls
    
        }
    }

function Drive-Access{ 

#Asks the user if they want to grant or remove drive access
#Either way, the script retrieves a list of groups and asks the end user which group they would like to give/take to/from the user they chose earlier
#The user inputs the group name and that data is used to add/remove the selected user to/from the group

    Write-Host "In order to grant/remove drive access, the user must be added(+)/removed(-) to or from a group" 
    "`n"  
    $access = Read-Host "Would you like to add or remove drive access? [+/-]"
    "`n"
    if($access -eq "+"){

        do{

            Get-ADGroup -Filter * | select name | sort | Format-Table
            $groups = Read-Host "Which groups would you like to give access to $user?" 
            Add-ADGroupMember -Identity $groups -Members $user
            "`n"
            $again = Read-Host "Would you like to add another? [Y/N]"

            }until($again -eq "N")
            

        }else{
    
        do{

            Get-ADGroup -Filter * | select name | sort | Format-Table
            $groups = Read-Host "Which groups would you like to remove $user from?" 
            Remove-ADGroupMember -Identity $groups -Members $user
            "`n"
            $again = Read-Host "Would you like to add another? [Y/N]"

            }until($again -eq "N")
        }
    }
  
function Main{

#Asks the end user if they want to manage a user/computer
#If the end user picks a user, they are then shown a list of users and a set of options 
#If the und user picks a computer, they are just shown a list of options
#Either way, the end user can change their mind and go back to configure one or the other

    $choice = Read-Host "Would you like to manage a user or manage a computer?"
    $choice.ToLower()
    cls
    
    if($choice -eq "user"){
    
            while($true){ 
    
                Get-ADUser -Filter * | select SamAccountName | Format-Table 
    
                $user = Read-Host "Which user would you like to manage? If there is no user you would like to manage then press 'q' to quit. If you want to configure something else press 'c'
                
" 

                if($user -eq "q"){
                
                    exit
                
                }

                if($user -eq "c"){
                
                    "`n"
                    Main
                
                }
    
                cls
                $action = Read-Host "Here are a list of choices: 
                
1.) Grant/remove drive access  
2.) Enable/disable a user
3.) Configure something else

What would you like to do with '$user'?"
    
                cls
    
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
5.) Configure something else"
        
            "`n"
            $action = Read-Host "What would you like to do?" 
            cls
        
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
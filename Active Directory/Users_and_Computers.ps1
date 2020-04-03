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
Write-Host "AD Users and Computers v0.6.0" 
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

        $name = Read-Host "Enter name"
        $description = Read-Host "Enter description"
        $path = Read-Host "Enter path (see README if unsure)"

        New-ADComputer -Name $name -Description $description -Path $path -Confirm

        "`n"
        $again = Read-Host "Would you like to create another? [Y/N]"
        $again.ToUpper() 

        }until($again -eq "N") 
    }

function Edit-Object{

    do{

        $computer = Read-Host "Which computer would you like to edit?"
        "`n"
        $desc = Read-Host "Enter new description" 

        Set-ADComputer -Identity $computer -Description $desc

        "`n" 
        $again = Read-Host "Would you like to edit another computer's description? [Y/N]" 
        $again.ToUpper()

        }until($again -eq "N")
    }

function Move-Object{

    do{

        $identity = Read-Host "Please enter the distinguished name of the object to move"
        "`n"
        $destination = Read-Host "Please enter in the destination of the object"

        Move-ADObject -Identity $identity -TargetPath $destination

        "`n"
        $again = Read-Host "Would you like to move another comptuer? [Y/N]" 
        $again.ToUpper()

        }until($again -eq "N")
    }

function Computer-Action{

    "`n"
    $nav = Read-Host "Would you like to perform another action? `n`nHere are your options again: `n`n1.) Create a new object `n2.) Edit an object's description `n3.) Move an object"
    
    if($nav -eq "1"){
    
        "`n"
        New-Object
    
    }
        
    if($nav -eq "2"){
    
        "`n"
        Edit-Object

    } 
    
    if($nav -eq "3"){ 

        "`n"
        Move-Object

    }  
    
} 
    
function Enable-Account{

    $enable = Read-Host "Press 1 to enable or press 0 to disable the account"
    "`n" 
    if($enable-eq "1"){
    
        Enable-ADAccount -Identity $user
        Write-Host "$user has been enabled"
        "`n" 
        Get-ADUser -Identity $user | select Enabled 
        "`n" 
        pause

    }else{
    
        Disable-ADAccount -Identity $user
        Write-Host "$user has been disabled" 
        "`n" 
        Get-ADUser -Identity $user | select Enabled
        "`n" 
        pause
    
        }
    }

function Drive-Access{ 

    Write-Host "In order to grant/remove drive access, the user must be added/removed to or from a group" 
    "`n"  
    $access = Read-Host "Would you like to add or remove drive access?"
    $access.ToLower()
    "`n"
    if($access -eq "add"){

        Get-ADGroup -Filter * | select name 
        "`n" 
        $groups = Read-Host "Which groups would you like to give access to $user?" 
        Add-ADGroupMember -Identity $groups -Members $user
    
    }else{
    
        Get-ADGroup -Filter * | select name
        "`n" 
        $groups = Read-Host "Which groups would you like to remove $user from?" 
        Remove-ADGroupMember -Identity $groups -Members $user
    
    }

}

function User-Action{

    $nav = Read-Host "Would you like to perform another action? `n`nHere are your options again: `n1.)Grant/remove drive access `
    2.) Enable/disable a user" 

    if($nav -eq "1"){
    
        Drive-Access
    
    }

    if($nav -eq "2"){
    
        Enable-Account
    
    }
}

$choice = Read-Host "Would you like to manage a user or manage a computer?"
$choice.ToLower()
cls

if($choice -eq "user"){
    
    do{

        Get-ADUser -Filter * | select Name
        "`n" 
        $user = Read-Host "Which user would you like to manage? If there is no user you would like to manage then press q" 
        cls
        $action = Read-Host "Here are a list of choices: `n1.) Grant/remove drive access  
        `n2.) Enable/disable a user `n`nWhat would you like to do with '$user'? "
        cls

        if($action -eq "1"){
        
            Drive-Access
            User-Action

        }

        if($action -eq "2"){
         
            Enable-Account
            User-Action

            }

        }until($user -eq "q")

    }

if($choice -eq "computer"){
   `
    Write-Host "Here are your list of choices: `n`n1.) Create a new object `n2.) Edit an object's description `
3.) Move an object"
    "`n" 
    $action = Read-Host "What would you like to do?" 
    "`n"

    if($action -eq "1"){
        
            New-Object
            Computer-Action 

        }

    if($action -eq "2"){

            Edit-Object
            Computer-Action

        }

    if($action -eq "3"){

            Move-Object
            Computer-Action 

        }
    }

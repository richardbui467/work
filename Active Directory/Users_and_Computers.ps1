Import-Module "activedirectory"

$b = echo "`n" 

cls 
echo "AD Users and Computers v0.1.0" 
$b
echo "This script allows you to create users and computers within Active Directory"
$b
echo "Made by Richard Bui 3/23/2020"
$b
pause
cls

$choice = Read-Host "Would you like to manage a user or manage a computer?"
$choice.ToLower()
if($choice -eq "user"){
    
    $user = Read-Host "Which user would you like to manage?" 
    $b
    $action = Read-Host "What would you like to do with this user?" 
    $b
    Read-Host "Here are your list of choices: Grant Drive Access, Remove Drive Access" 

}

if($choice -eq "computer"){
   
    $action = Read-Host "What would you like to do?" 
    $b
    Read-Host "Here are your list of choices: `n{Create} a new object `n{Edit} an object's description `
{Move} an object"
    $action.ToLower()

    if($action -eq "create"){

        do{

            $name = Read-Host "Enter name"
            $description = Read-Host "Enter description"
            $path = Read-Host "Enter path (see README if unsure)"

            New-ADComputer -Name $name -Description $description -Path $path -Confirm

            $again = Read-Host "Would you like to create another? [Y/N]"
            $again.ToUpper() 

        }until($again -eq "N") 


    if($action -eq "edit"){
        
        do{

            $computer = Read-Host "Which computer would you like to edit?"
            $b
            $desc = Read-Host "Enter new description" 

            Set-ADComputer -Identity $computer -Description $desc

            $again = Read-Host "Would you like to edit another computer's description? [Y/N]" 
            $again.ToUpper()

        }until($again -eq "N")


    if($action -eq "move"){

        do{

            

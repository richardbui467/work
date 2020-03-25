#These variables store the output of the directory listings in the respective paths, also sorts the results in alphabetical order

$x86 = dir "C:\Program Files (x86)" | sort
$x64 = dir "C:\Program Files\" | sort 
$C = dir "C:\" | sort 
$Start = dir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" | sort

#This is a variable to the path that I'm going to be referring to a lot in order to append the text file

$path = "C:\softwareScript\local_software0.txt" 

#The first command will create the text file with the directory listing of Program Files (x86) inside of it
#The command after append more directory listings from different paths

Set-Content $path $x86 
Add-Content $path $x64
Add-Content $path $C
Add-Content $path $Start

#Sorts out the list and eliminates any repeating lines and deletes the old file

gc $path | sort | get-unique > "C:\softwareScript\local_software.txt"
Remove-Item $path 

#This adds a bunch of information for the user to see on their shell, the $b variable adds blank lines

$b = echo "`n" 

cls
echo "Software Script v1.3, updated 3/9/2020"
$b
echo "Made by Richard Bui 3/4/2020" 
$b
echo "This script retrieves a list of installed software on the local computer and compares it to either the lab, classroom, or standard software sets to see if the local machine is missing any software."
$b
echo "While checking the results, a side indicator of '<=' or two of the same string means that the software is installed. Whereas a side indicator of '=>' means that the software is not installed."
$b
echo "Fair warning that this script is not 100% accurate. There may be programs that the script says aren't there but really they are. You should get some pretty narrow results though so be sure to verify what the script says is not installed."
$b
pause
$b

#This section prompts the user for which set of software they would like to compare their local software to 
#The user selects the set of software, and then the script retrieves the content of the respective list to compare
#But if the user has any more software they would like to compare that isn't within the default list, then the shell will ask them
#If they say yes, a copy of the list they chose is made and is used to have the extra software appended to it 
#The script goes into a loop asking for extra software until the user hits "N"

$strReference = Get-Content "C:\softwareScript\local_software.txt"
$List = Read-Host -Prompt "Which set of software would you like to compare the local computer's software to? [{L}ab/{C}lassroom/{S}tandard]"
$b
if ($List -eq "L"){ 
 

    $strDifference = Get-Content "C:\softwareScript\Standard Software\lab_software.txt"

    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    $b
    if($append -eq "Y"){
        
        Copy-Item "C:\softwareScript\Standard Software\lab_software.txt" "C:\softwareScript\Standard Software\lab_software_extra.txt" 

        do{

            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            $b
            Add-Content -path "C:\softwareScript\Standard Software\lab_software_extra.txt" -value "`n$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"

        }until($again -eq "N")  

        $strDifference = Get-Content "C:\softwareScript\Standard Software\lab_software_extra.txt"

    } 
}

if ($List -eq "C"){ 

    $strDifference = Get-Content "C:\softwareScript\Standard Software\class_software.txt"
    
    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    $b
    if($append -eq "Y"){
        
        Copy-Item "C:\softwareScript\Standard Software\lab_software.txt" "C:\softwareScript\Standard Software\class_software_extra.txt" 

        do{

            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            $b
            Add-Content -path "C:\softwareScript\Standard Software\class_software_extra.txt" -value "`n$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"

        }until($again -eq "N")  

        $strDifference = Get-Content "C:\softwareScript\Standard Software\class_software_extra.txt"

    } 
}

if ($List -eq "S"){

  $strDifference = Get-Content "C:\softwareScript\Standard Software\standard_software.txt"

    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    $b
    if($append -eq "Y"){
        
        Copy-Item "C:\softwareScript\Standard Software\lab_software.txt" "C:\softwareScript\Standard Software\standard_software_extra.txt" 

        do{

            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            $b
            Add-Content -path "C:\softwareScript\Standard Software\standard_software_extra.txt" -value "`n$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"

        }until($again -eq "N")  

        $strDifference = Get-Content "C:\softwareScript\Standard Software\standard_software_extra.txt"

    } 
}
$b

#Creates the conditional statement for when the user wants to save a copy of the installed software on the local computer
#If they say "Y", then the local_software.txt file will be moved from the directory of "softwareScript" to wherever the user wants in the full path they will be prompted to input
#If they say "N", then the script will just move on and compare "local_software.txt" to the text file that has all the software on it

$Save = Read-Host -Prompt "Would you like to keep a list of the installed software on your computer? [Y/N]"
if ($Save -eq "N"){

    Remove-Item "C:\softwareScript\local_software.txt"

}else {

    $b
    $Y = Read-Host -Prompt "Where would you like the file to be saved? Please enter in the full path" 
    Move-Item "C:\softwareScript\local_software.txt" $Y -Force
    $b
    echo "local_software.txt has been saved in $Y!"

}
$b

#Asks the user where they want the results to be saved 
#Compare-Object compares "lab_software" with "local_software"

$Results = Read-Host -Prompt "Where would you like the results to be saved? Please enter in the full path"

Compare-Object $strReference $strDifference > "$Results\results.txt"
$b
echo "Results has been saved to results.txt located in $Results!"

#Gets rid of the "extra" text file to reduce clutter

Remove-Item "C:\softwareScript\Standard Software\*_extra.txt"
$b

Read-Host -Prompt "Press Enter to exit"
cls

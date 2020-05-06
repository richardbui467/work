$pwd = Get-Location

#These variables store the output of the Get-ChildItemectory listings in the respective paths, also sorts the results in alphabetical order

$x86 = Get-ChildItem "$env:ProgramFiles (x86)" | sort
$x64 = Get-ChildItem "$env:ProgramFiles" | sort 
$C = Get-ChildItem "$env:SystemDrive" | sort 
$Start = Get-ChildItem "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" | sort

$path = "$pwd\local_software0.txt" 

#The first command will create the text file with the Get-ChildItemectory listing of Program Files (x86) inside of it
#The command after append more Get-ChildItemectory listings from different paths

Set-Content $path $x86 
Add-Content $path $x64
Add-Content $path $C
Add-Content $path $Start

#Sorts out the list, eliminates any repeating lines, deletes the old file

gc $path | sort | get-unique > "$pwd\local_software.txt"
Remove-Item $path 

Clear-Host
Write-Host "Software Script v1.3.4, updated 5/4/2020

Made by Richard Bui 3/4/2020

This script retrieves a list of installed software on the local computer and compares it to either the lab, classroom, or standard software sets to see if the local machine is missing any software.

While checking the results, a side indicator of '<=' or two of the same string means that the software is installed. Whereas a side indicator of '=>' means that the software is not installed.

Fair warning that this script is not 100% accurate. There may be programs that the script says aren't there but really they are. You should get some pretty narrow results though so be sure to verify what the script says is not installed.

"

pause

#Prompts user for a set of software and any other extra software they would like to juxtapose

$strReference = Get-Content "$pwd\local_software.txt"
$List = Read-Host -Prompt "Which set of software would you like to compare the local computer's software to? [{L}ab/{C}lassroom/{S}tandard]"
"`n"

if ($List -eq "L"){ 
 
    $strDifference = Get-Content "$pwd\SoftwareSets\lab_software.txt"
    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    if($append -eq "Y"){
        
        Copy-Item "$pwd\SoftwareSets\lab_software.txt" "$pwd\SoftwareSets\lab_software_extra.txt" 

        do{
	    
	    "`n"
            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            "`n"
            Add-Content -path "$pwd\SoftwareSets\lab_software_extra.txt" -value ""`n"$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"

        }until($again -eq "N")  

        $strDifference = Get-Content "$pwd\SoftwareSets\lab_software_extra.txt"

    } 
}

if ($List -eq "C"){ 

    $strDifference = Get-Content "$pwd\SoftwareSets\class_software.txt"
    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    "`n"
    if($append -eq "Y"){
        
        Copy-Item "$pwd\SoftwareSets\lab_software.txt" "$pwd\SoftwareSets\class_software_extra.txt" 

        do{

            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            "`n"
            Add-Content -path "$pwd\SoftwareSets\class_software_extra.txt" -value "$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"

        }until($again -eq "N")  

        $strDifference = Get-Content "$pwd\SoftwareSets\class_software_extra.txt"

    } 
}

if ($List -eq "S"){

    $strDifference = Get-Content "$pwd\SoftwareSets\standard_software.txt"
    $append = Read-Host -Prompt "Would you like to add any additional software to compare? [Y/N]"
    "`n"
    if($append -eq "Y"){
        
        Copy-Item "$pwd\SoftwareSets\lab_software.txt" "$pwd\SoftwareSets\standard_software_extra.txt" 

        do{

            $request = Read-Host -Prompt "Which software would you like to add? Please enter one at a time." 
            "`n"
            Add-Content -path "$pwd\SoftwareSets\standard_software_extra.txt" -value ""`n"$request"
            $again = Read-Host -Prompt "Would you like to add another piece of software? [Y/N]"
	    

        }until($again -eq "N")  

	"`n"
        $strDifference = Get-Content "$pwd\SoftwareSets\standard_software_extra.txt"

    } 
}

#Copies list of installed software
"`n"
$Save = Read-Host -Prompt "Would you like to keep a list of the installed software on your computer? [Y/N]"
if ($Save -eq "N"){

    Remove-Item "$pwd\local_software.txt"

}else {

    "`n"
    $Y = Read-Host -Prompt "Where would you like the file to be saved? Please enter in the full path" 
    Move-Item "$pwd\local_software.txt" $Y -Force
    "`n"
    Write-Host "local_software.txt has been saved in $Y!"

}
"`n"

#Saves results of comparison
$Results = Read-Host -Prompt "Where would you like the results to be saved? Please enter in the full path"
Compare-Object $strReference $strDifference > "$Results\results.txt"
"`n"
Write-Host "Results has been saved to results.txt located in $Results!"
Remove-Item "$pwd\SoftwareSets\*_extra.txt"
"`n"
Read-Host -Prompt "Press Enter to exit"
Clear-Host

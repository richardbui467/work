There is an execution policy with powershell scripts, and the script may not run properly depending on the policy.

You will know that the script cannot run if you open it with powershell and it immediately closes.

To fix this, run the following command in an elevated powershell session:

Set-ExecutionPolicy -ExecutionPolicy Bypass

This lifts the restrictions for powershell scripts. Since this script is not digitally signed, the execution policy will prevent it from running.


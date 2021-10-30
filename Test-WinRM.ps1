############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : This script tests the WinRM connectivity to resource
# VERSION : 1.3
############################################################### 

#---------------------------------------------------------- 
#FUNCTION AND PARAMETERS
#---------------------------------------------------------- 
function TestWinRM {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('ComputerName')]
        [string[]]$computers
    )
#---------------------------------------------------------- 
# SCRIPT - TEST WINRM
#----------------------------------------------------------  
    BEGIN{}
    PROCESS {

        foreach ($computer in $computers) {
         $WSMan = Test-WSMan -ComputerName $computer -ErrorAction "silentlycontinue" | Select-Object ProductVendor
            if ($WSMan.ProductVendor -eq "Microsoft Corporation"){
                Write-Host "$computer WinRM is working" 
                $winRMComputers = New-Object PSObject
                Add-Member -InputObject $winRMComputers -MemberType NoteProperty -Name Computers -Value $computer
                Write-Output $winRMComputers 
            }else {
                Write-Host "$computer WinRM is not working" 
            }
        }
    }
    END{}
}

Import-Csv .\csv\computers.csv | TestWinRM  | Out-File .\log\WinRMComputers.csv
############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : AddServersToADGroup
# VERSION : 1.0
############################################################### 

#---------------------------------------------------------- 
#FUNCTION AND PARAMETERS
#---------------------------------------------------------- 
function AddServersToADGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string[]]$Servers,
                [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string]$Group
    )
#---------------------------------------------------------- 
# SCRIPTBLOCK
#----------------------------------------------------------  
    BEGIN{}
    PROCESS {
        Import-Module ActiveDirectory
            for ($i = 0; $i -lt $Servers.Length; $i++){
                [string]$SerString = $Servers[$i]
                $date = Get-Date 
                try {
                    Add-ADGroupMember -id $Group -MEMBERS (Get-ADComputer $Servers[$i])      
                    Write-Output "$date [INFO] $SerString is added to $Group" | Out-File ".\output.log" -Append
                } catch {
                    Write-Output "$date [ERROR] $SerString : $_.Exception.Message" | Out-File ".\output.log" -Append
                }
            }
    }
    END{}
} 

#---------------------------------------------------------- 
# CALL FUNCTION WITH PARAMS
#---------------------------------------------------------- 

[string[]]$InpServers = Get-Content $ListPath
AddServersToADGroup -Servers $InpServers -Group $Group

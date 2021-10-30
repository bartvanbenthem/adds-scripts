############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : Find old AD computer objects
# VERSION : 1.0
############################################################### 

Function GetOldComputers {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$domainController,
        [Parameter(Mandatory=$true)]
        [psobject]$credential,
        [Parameter(Mandatory=$true)]
        [string]$domain
    )

    Invoke-Command -ComputerName $domainController -Credential $credential -ScriptBlock {
        import-module activedirectory  
        $domain = $using:domain
        $DaysInactive = 90  
        $time = (Get-Date).Adddays(-($DaysInactive))
  
        # Get all AD computers with lastLogonTimestamp less than our time 
        Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp |  
        # Output hostname and lastLogonTimestamp
        select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
    }
}

$domaincontrollers = @("<domain controller(s)>")

foreach ($domaincontroller in $domaincontrollers){
    $domainpartials = $domaincontroller.Split('.')
    $domain = ($domainpartials[1] + "." + $domainpartials[2] + "." + $domainpartials[3])
    $credential = Get-Credential "<service account>"

    $var = GetOldComputers -domainController $domaincontroller -credential $credential -domain $domain
    $var | Select-Object Name, Stamp 
}

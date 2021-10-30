############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : This script creates Domain Service accounts from
#           CSV input.
# VERSION : 0.5
############################################################### 

#---------------------------------------------------------- 
#CREATE FUNCTION
#---------------------------------------------------------- 
function NewADServiceAccount {
    [CmdletBinding()]
    Param (
          
        [Parameter(Mandatory=$true)]
        [string]$dc,
        [psobject]$credential,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('Name')]
        [psobject[]]$ServiceAccounts,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Description,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Path,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Password

    )
    BEGIN{}
    PROCESS {

#---------------------------------------------------------- 
#START ACCOUNT PROPERTY COLLECTION
#---------------------------------------------------------- 
     Invoke-Command -ComputerName $dc -Credential $credential -scriptblock {
        foreach ($user in $using:ServiceAccounts) {
             [string]$domain = $env:userdnsdomain
             [string]$UserName = $user.Name
             [string]$UPN = "$UserName@$domain"
             [string]$SAM = $user.Name 
             [string]$Description = $user.Description
             [string]$OU = $user.Path
             [string]$Password = $user.Password

#---------------------------------------------------------- 
#START ACCOUNT CREATION
#---------------------------------------------------------- 
            New-ADUser -Name $UserName `
            -UserPrincipalName $UPN `
            -SamAccountName $SAM `
            -DisplayName $UserName `
            -Description $Description `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true `
            -Path $OU `
            -PasswordNeverExpires $true `
            -CannotChangePassword $true
             
#---------------------------------------------------------- 
#DENY LOGON RDSH
#---------------------------------------------------------- 
            $RDSH = [ADSI]"LDAP://CN=$username,$OU"
            $RDSH.SamAccountName #to check the account
            $RDSH.psbase.invokeSet("allowLogon",0)
            $RDSH.setinfo()
        }
     }
   }
   END{}
}

[psobject]$admin = Get-Credential "<service account>"
Import-Csv .\csv\prodSrvcAccounts.csv | NewADServiceAccount -dc "<domain controller>" -credential $admin

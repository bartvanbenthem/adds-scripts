############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : This script creates Domain User accounts from
#           CSV input.
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
        [psobject[]]$GivenName,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Surname,
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
        [string[]]$Password,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$EmailAddress

    )
    BEGIN{}
    PROCESS {
#---------------------------------------------------------- 
#START ACCOUNT PROPERTY COLLECTION
#----------------------------------------------------------  
    Invoke-Command -ComputerName $dc -Credential $credential -scriptblock {
        foreach ($user in $using:GivenName) {
                 [string]$domain = $env:userdnsdomain
                 [string]$GivenName = $user.GivenName
                 [string]$SurName = $user.Surname
                 [string]$UserName = "$givenName$surName"
                 [string]$UPN = "$givenName$surName@$domain"
                 [string]$SAM = "$givenName$surName"
                 [string]$Description = $user.Description
                 [string]$OU = $user.Path
                 [string]$Password = $user.Password
                 [string]$email = $user.EmailAddress

#---------------------------------------------------------- 
#START ACCOUNT CREATION
#---------------------------------------------------------- 
                New-ADUser -Name $UserName `
                -GivenName $GivenName `
                -Surname $SurName `
                -SamAccountName $UserName `
                -UserPrincipalName $UPN `
                -DisplayName $UserName `
                -Description $Description `
                -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
                -Enabled $true `
                -Path $OU `
                -EmailAddress $email `
                -PasswordNeverExpires $false `
                -CannotChangePassword $false `
                -ChangePasswordAtLogon $true
        }
      }
    }
    END{}
}

[psobject]$admin = Get-Credential "<service account>"
Import-Csv .\csv\prodUsrAccounts.csv | NewADServiceAccount -dc "<domain controller>" -credential $admin


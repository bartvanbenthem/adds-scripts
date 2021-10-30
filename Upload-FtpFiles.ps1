############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : Upload-FTPFiles
# VERSION : 1.0
############################################################### 

# Example: Powershell.exe -File .\UploadFtpFiles.ps1 -Username "username" \
# -Password "password" -LocalFile "local_filepath/filename" -RemoteFile "ftp_path/filename"

# Parameters to pass to .ps1 script file
Param([string]$Username, [string]$Password, [string]$LocalFile, [string]$RemoteFile)

#---------------------------------------------------------- 
#FUNCTION AND PARAMETERS UPLOAD-FTPFILES
#---------------------------------------------------------- 
function UploadFtpFiles {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string]$LocalFile,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string]$RemoteFile
    )
#---------------------------------------------------------- 
# SCRIPTBLOCK - UPLOAD-FTPFILES
#----------------------------------------------------------  
    BEGIN{}
    PROCESS {
        $FTPRequest = [System.Net.FtpWebRequest]::Create(“$RemoteFile”)
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $FTPRequest.Credentials = new-object System.Net.NetworkCredential($Username, $Password)
        $FTPRequest.UseBinary = $true
        $FTPRequest.UsePassive = $false
        $FileContent = [System.IO.File]::ReadAllBytes(“$LocalFile”)
        $FTPRequest.ContentLength = $FileContent.Length
        $Run = $FTPRequest.GetRequestStream()
        $Run.Write($FileContent, 0, $FileContent.Length)
        $Run.Close()
        $Run.Dispose()
    }
    END{
    }
} 

#---------------------------------------------------------- 
# CALL FUNCTION WITH PARAMS
#---------------------------------------------------------- 

UploadFtpFiles -Username $Username -Password $Password -LocalFile $LocalFile -RemoteFile $RemoteFile
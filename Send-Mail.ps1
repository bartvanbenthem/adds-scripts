############################################################### 
# AUTHOR  : Bart van Benthem
# COMMENT : script to send mail
# VERSION : 0.5
############################################################### 

#Set Variables
$Date = Get-Date
$ErrorLogFile = ".\log\error.log"
$Attachment = Get-ChildItem ".\attachment\*"

#Sending e-mail
Write-Host "Sending email" -Verbose
Try { 
      $mail = Send-MailMessage -From "name@domain.nl" `
                       -To "name@domain.com" `
                       -Subject "subject" `
                       -Body "body text" `
                       -SmtpServer "mailrelay.domain.com" `
                       -Attachments $Attachment `
                       -ErrorAction Stop
}
Catch {
        Write-Host "The email has not been send because of an Error"
        $Date | Out-File $ErrorLogFile -Append
        $Error | Out-File $ErrorLogFile -Append
        Write-Host "Check $ErrorLogFile for more information"
}
Finally {
          Read-Host -Prompt "Press Enter to continue"
          #write-host "Press any key to continue..."
          #[void][System.Console]::ReadKey($true)
}

       

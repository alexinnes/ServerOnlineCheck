function Update-ServerReport {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        #location of output file
        [Parameter(Mandatory=$false)]
        $output_location = "C:\temp",

        #Severity of message
        [Parameter(Mandatory=$true)]
        [validateset("Info","Warning", "Error")]
        $message_severity,

        #Message to be logged.
        [Parameter(Mandatory=$true)]
        $Message
    )

        $date = Get-Date -format g
        $filePath = "$output_location\"
        $fileName = "ServerReport.log"
        $file = "$filePath$fileName"
        if (!(Test-Path $file)){
            New-Item -Path $filePath -name $fileName -ItemType "file"  -Force | Out-Null
        }

        $log_message = "$date :: $($message_severity) - $message `n"
        $log_message | Out-File -FilePath $file -Append -Force

}


$servers = Get-VM

foreach($serv in $servers){

    #Hyper-V Running Test
    $nic = $serv.networkadapters | where{$_.status -eq "OK"} | select -ExpandProperty ipaddresses | where {$_ -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"}
    If($serv.State -ne "Running"){

        $messageHypervState = "$($serv.Name) - Server not running in Hyper-V: $($serv.state)"
        Write-Warning $messageHypervState
        Update-ServerReport -message_severity Error -Message $messageHypervState
    }else{
        $messageHypervState = "$($serv.name) - Hyper-V: Running"
        write-host -BackgroundColor Green $messageHypervState
        Update-ServerReport -message_severity Info -Message $messageHypervState

    }

    #Ping Test
    $ping = Test-Connection $nic -Count 4 -Quiet
    if(!($ping)){
        $messagePing =  "$($serv.Name) - no Ping responce"
        Write-Warning $messagePing
        Update-ServerReport -message_severity Error -Message $messagePing

    }else{
        $messagePing = "$($serv.name) - Ping: Good"
        write-host -BackgroundColor Green $messagePing
        Update-ServerReport -message_severity Info -Message $messagePing
    }

    #WMI Test
    try{
        $WMITest = Get-WmiObject -Class win32_process -ErrorAction Stop
    }
    catch{
        $messageWMI = "$($serv.Name) - no WMI responce. Check PING and Hyper-V status, WMI might not be open on this server."
        Write-Warning $messageWMI
        Update-ServerReport -message_severity Warning $messageWMI
    }

    if(!($WMITest)){
        $messageWMI = "$($serv.Name) - no WMI responce. Check PING and Hyper-V status, WMI might not be open on this server."
        Write-Warning $messageWMI
        Update-ServerReport -message_severity Warning -Message $messageWMI
    }else{
        $messageWMI = "$($serv.name) - WMI: Good"
        write-host -BackgroundColor Green $messageWMI
        Update-ServerReport -message_severity Info -Message $messageWMI
    }

    #AdminShare Test
    $adminShare = "$($serv.name)\c`$"

    If(Test-Path $adminShare){
        $messageAdmin = "$($serv.name) - Admin Share (C`$): Good `n"
        Update-ServerReport -message_severity Info -Message $messageAdmin
    }else{
        $messageAdmin = "$($serv.name) - Admin Share (C`$): Error cannot location Admin Share"
        Write-Warning $messageAdmin
        Update-ServerReport -message_severity Error -Message $messageAdmin
    }




    }



}


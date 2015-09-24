Get-WinEvent -FilterHashtable @{
    LogName = "Windows PowerShell";
    ID=800;
} -ComputerName "u05pc19"| select -first 50 | % { ([xml]$_.ToXml()).Event.EventData.Data[2] }
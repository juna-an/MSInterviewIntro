# Connecting to the VM
Get-AzVM -ResourceGroupName "ja-arm-intro-task" -Name "simple-vm"

$result = Invoke-AzVMRunCommand -ResourceGroupName 'ja-arm-intro-task' `
  -Name 'simple-vm' `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath 'moveScript.ps1'
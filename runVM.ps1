$srcKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount3rg").Value[0]
$destKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount4rg").Value[0]

$paramValues = @{
    sourceStorageKey = $srcKey
    destStorageKey = $destKey
}

# Connecting to the VM
Get-AzVM -ResourceGroupName "ja-arm-intro-task" -Name "simple-vm"

$result = Invoke-AzVMRunCommand -ResourceGroupName 'ja-arm-intro-task' `
  -Name 'simple-vm' `
  -CommandId 'RunPowerShellScript' `
  -ScriptPath 'moveScript.ps1' `
  -Parameter $paramValues
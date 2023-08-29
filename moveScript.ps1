# Storage account details
$sourceStorageAccount = "storageaccount3rg"
$sourceStorageKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount3rg").Value[0]
$destStorageAccount = "storageaccount4rg"
$destStorageKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount4rg").Value[0]
$srcContext = New-AzStorageContext -StorageAccountName $sourceStorageAccount -StorageAccountKey $sourceStorageKey
$destContext = New-AzStorageContext -StorageAccountName $destStorageAccount -StorageAccountKey $destStorageKey
$srcContainerName = "src-container-a"
$destContainerName = "dest-container-b"

# Local variables
$numOfBlobs = 3

# Create a dummy file and copy it to the disired number of blobs in storage account a
# and then copying it to the storage account b
# Specify the file path
$filePath = "file.txt"
# Write the string to the file
"hello world" | Out-File -FilePath $filePath

# Create $numOfBlobs blobs in source storage account
Write-Host "**************************************************************"
Write-Host "******************** Statr creating blobs ********************"
for ($i = 1; $i -le $numOfBlobs; $i++) {
    $blobName = "blob$i.txt"
    Write-Host -NoNewline "Creating blob: $blobName, "
    $setBlobCommand = Set-AzStorageBlobContent -Container $srcContainerName `
        -Blob $blobName `
        -BlobType Block `
        -File $filePath `
        -Context $srcContext
}
Write-Host ""
Write-Host "****************** Finished creating blobs! ******************"
Write-Host "**************************************************************"

# Copy blobs from source storage account to destination storage account
Write-Host "**************************************************************"
Write-Host "********************* Statr copying blobs ********************"
for ($i = 1; $i -le $numOfBlobs; $i++) {
    $blobName = "blob$i.txt"
    Write-Host -NoNewline "Copying blob: $blobName, "
    $sourceUri = "https://$sourceStorageAccount.blob.core.windows.net/$srcContainerName/$blobName"
    $sourceBlob = Get-AzStorageBlob -Context $srcContext `
        -Container $srcContainerName `
        -Blob $blobName

    $destinationBlob = Start-AzStorageBlobCopy `
        -Context $srcContext `
        -DestContext $destContext `
        -SrcBlob $sourceBlob.Name `
        -SrcContainer $srcContainerName `
        -DestContainer $destContainerName `
        -DestBlob $blobName

    # Monitor the copy status if needed
    $copyStatus = $destinationBlob | Get-AzStorageBlobCopyState
    $copyStatus.Status

}
Write-Host ""
Write-Host "******************* Finished copying blobs! ******************"
Write-Host "**************************************************************"

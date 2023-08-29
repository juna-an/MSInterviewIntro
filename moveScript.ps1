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
"hello world454637" | Out-File -FilePath $filePath

# Create $numOfBlobs blobs in source storage account
Write-Host "**************************************************************"
Write-Host "******************** Statr creating blobs ********************"
Write-Host -NoNewline "Creating blob: "
for ($i = 1; $i -le $numOfBlobs; $i++) {
    $blobName = "blob$i.txt"
    Write-Host -NoNewline "$blobName, "
    $sourceBlob = Get-AzStorageBlob -Context $srcContext `
        -Container $srcContainerName `
        -Blob $blobName `
        -ErrorAction SilentlyContinue

    $setBlobCommand = Set-AzStorageBlobContent -Container $srcContainerName `
        -Blob $blobName `
        -BlobType Block `
        -File $filePath `
        -Context $srcContext `
        -Force
}
Write-Host ""
Write-Host "****************** Finished creating blobs! ******************"
Write-Host "**************************************************************"
Write-Host ""

# Copy blobs from source storage account to destination storage account
Write-Host "**************************************************************"
Write-Host "********************* Statr copying blobs ********************"
Write-Host -NoNewline "Copying blobs: "
for ($i = 1; $i -le $numOfBlobs; $i++) {
    $blobName = "blob$i.txt"
    Write-Host -NoNewline "$blobName, "
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
        -DestBlob $blobName `
        -Force

    # Monitor the copy status if needed
    # $copyStatus = $destinationBlob | Get-AzStorageBlobCopyState
    # $copyStatus.Status

}
Write-Host ""
Write-Host "******************* Finished copying blobs! ******************"
Write-Host "**************************************************************"
Write-Host ""

Write-Host "**************************************************************"
Write-Host "**************** Statr deleting blobs from SA A **************"
Write-Host -NoNewline "Deleting all blobs in source storage account!"
for ($i = 1; $i -le $numOfBlobs; $i++) {
    $blobName = "blob$i.txt"
    Remove-AzStorageBlob -Context $srcContext -Container $srcContainerName -Blob $blobName
}

Write-Host ""
Write-Host "*************** Finished deleting blobs from SA A ************"
Write-Host "**************************************************************"

# # Delete a container recursivly
# # List blobs in the container
# $blobs = Get-AzStorageBlob -Context $srcContext -Container $srcContainerName
# # Delete each blob in the container
# foreach ($blob in $blobs) {
#     Remove-AzStorageBlob -Context $srcContext -Container $srcContainerName -Blob $blob.Name -Force
# }

# # Delete the now-empty container
# Remove-AzStorageContainer -Name $srcContainerName -Context $srcContext -Force
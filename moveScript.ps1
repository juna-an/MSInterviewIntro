# comment

param(
    $sourceStorageKey,
    $destStorageKey
)

# Checking if the Az.Storage module is installed and installing it if not
    # Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    # Install-Module -Name Az -Repository PSGallery -Force
    # Update-Module -Name Az -Force
    # Connect-AzAccount -Subscription 961ea96e-ac1e-49d0-baae-b5156658e8ae
if (-not (Get-Module -ListAvailable Az.Storage)) {
  Install-Module -Name Az.Storage -Force
}



# Storage account details
$sourceStorageAccount = "storageaccount3rg"
# $sourceStorageKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount3rg").Value[0]
$destStorageAccount = "storageaccount4rg"
# $destStorageKey = (Get-AzStorageAccountKey -ResourceGroupName "ja-arm-intro-task" -Name "storageaccount4rg").Value[0]

###########################################################################
##################### Creating or updating containers #####################
# Creating containers of both storage accounts
$srcContext = New-AzStorageContext -StorageAccountName $sourceStorageAccount -StorageAccountKey $sourceStorageKey
$destContext = New-AzStorageContext -StorageAccountName $destStorageAccount -StorageAccountKey $destStorageKey
$srcContainerName = "src-container-a"
$destContainerName = "dest-container-b"

# Check if the container exists in the source storage account
$containerExists = Get-AzStorageContainer -Name $srcContainerName -Context $srcContext -ErrorAction SilentlyContinue
if (-not $containerExists) {
    # Create the container if it doesn't exist
    New-AzStorageContainer -Name $srcContainerName -Context $srcContext
    Write-Host "Container '$srcContainerName' created."
}

# Check if the container exists in the destination storage account
$destinationContainerExists = Get-AzStorageContainer -Name $destContainerName -Context $destContext -ErrorAction SilentlyContinue
if (-not $destinationContainerExists) {
    # Create the container if it doesn't exist
    New-AzStorageContainer -Name $destContainerName -Context $destContext
    Write-Host "Container '$destContainerName' created."
}
################## End of Creating or updating containers #################
###########################################################################


###########################################################################
########################## Creating a dummy file ##########################
# Create a dummy file and copy it to the disired number of blobs in storage account a
# and then copying it to the storage account b
# Specify the file path
$filePath = "file.txt" 
# Write the string to the file
"hello world! Do not worry be happy YOLO" | Out-File -FilePath $filePath
###################### End of Creating a dummy file #######################
###########################################################################


###########################################################################
######################## Creating $numOfBlobs blobs #######################
# Local variables
$numOfBlobs = 5
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
##################### End of Creating $numOfBlobs blobs ###################
###########################################################################


###########################################################################
######################## Copying $numOfBlobs blobs ########################
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
##################### End of Copying $numOfBlobs blobs ####################
###########################################################################


###########################################################################
#################### Deleting $numOfBlobs blobs from src ##################
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
################# End of Deleting $numOfBlobs blobs from src ##############
###########################################################################

########################## Debuging Helpers section #######################
###########################################################################
# # Delete a container recursivly
# # List blobs in the container
# $blobs = Get-AzStorageBlob -Context $srcContext -Container $srcContainerName
# # Delete each blob in the container
# foreach ($blob in $blobs) {
#     Remove-AzStorageBlob -Context $srcContext -Container $srcContainerName -Blob $blob.Name -Force
# }

# # Delete the now-empty container
# Remove-AzStorageContainer -Name $srcContainerName -Context $srcContext -Force

# # Delete blobs from destination storage account
# for ($i = 1; $i -le $numOfBlobs; $i++) {
#     $blobName = "blob$i.txt"
#     Remove-AzStorageBlob -Context $destContext -Container $destContainerName -Blob $blobName
# }

# # checking if the vm runs the script above by trying to creat a dummy file on it
# "HELLO MY NAME IS STRING" | Out-File -FilePath "C:\Hi.txt"

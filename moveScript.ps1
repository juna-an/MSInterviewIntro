# Replace these with your actual storage account details
$sourceStorageAccount = "source_storage_account_name"
$sourceStorageKey = "source_storage_account_key"
$destinationStorageAccount = "destination_storage_account_name"
$destinationStorageKey = "destination_storage_account_key"

# Specify the file path
$filePath = "file.txt"

# Write the string to the file
"hello world" | Out-File -FilePath $filePath

# Create 100 blobs in source storage account
for ($i = 1; $i -le 100; $i++) {
    $blobName = "blob$i.txt"
    Write-Host "Creating blob: $blobName"
    az storage blob upload --account-name $sourceStorageAccount --account-key $sourceStorageKey --container-name containerA --name $blobName --type block --source "C:\path\to\local\file.txt"
}

# Copy blobs from source storage account to destination storage account
for ($i = 1; $i -le 100; $i++) {
    $blobName = "blob$i.txt"
    Write-Host "Copying blob: $blobName"
    $sourceUri = "https://$sourceStorageAccount.blob.core.windows.net/containerA/$blobName?$sourceStorageKey"
    az storage blob copy start-batch --destination-container containerB --destination-blob $blobName --destination-path $blobName --source-uri $sourceUri
}

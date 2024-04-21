Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
#Check if you have AzureAD module installed
if (-not (Get-Module -Name AzureAD -ListAvailable)) {
    Write-Host "AzureAD module is not installed. Installing now..."
    try {
        # Install AzureAD module with execution policy set to Unrestricted
        Install-Module -Name AzureAD -Force -Scope CurrentUser -AllowClobber -Repository PSGallery -Verbose
    } catch {
        Write-Error "Failed to install AzureAD module."
        exit
    }
}

Write-Host "Script for importing security groups into Entra ID - Written by Harry Shelton"

#Connects you to AzureAD/Entra ID
Import-Module -Name AzureAD
Connect-AzureAD

Write-Host "CSV File should use following format: Name;Owner;Description;Members"
Write-Host "Only add one owner in your CSV"
$csvPath = Read-Host "Enter CSV Exact Path E.g. C:\temp\file.csv"
Write-Host "You entered: $csvPath"

# Import CSV and iterate through each row
Import-Csv -Path $csvPath -Delimiter ';' | ForEach-Object {
    # Extract values from CSV columns
    $groupName = $_.Name
    $ownerEmail = $_.Owner
    $description = $_.Description
	$members = $_.Members -split ','

    # Check if the owner exists in Azure AD
    $owner = Get-AzureADUser -Filter "UserPrincipalName eq '$ownerEmail'"
    if ($owner -eq $null) {
        Write-Warning "Owner with email '$ownerEmail' not found in Azure AD. Skipping group creation for '$groupName'."
    }
    else {
        # Generate mailNickname (replacing invalid characters)
        $mailNickname = $groupName -replace '[^a-zA-Z0-9-]', ''

        # Create the group as a security group
        $group = New-AzureADGroup -DisplayName $groupName -Description $description -MailEnabled $false -SecurityEnabled $true -MailNickname $mailNickname

        # Add the owner to the group
        Add-AzureADGroupOwner -ObjectId $group.ObjectId -RefObjectId $owner.ObjectId
        Write-Output "'$groupName' created successfully with owner '$ownerEmail' added."

        # Add members to the group
        foreach ($memberEmail in $members) {
            $member = Get-AzureADUser -Filter "UserPrincipalName eq '$memberEmail'"
            if ($member -eq $null) {
                Write-Warning "'$memberEmail' not found in Azure AD. Skipping adding member to group '$groupName'."
            }
            else {
                Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $member.ObjectId
                Write-Output "'$memberEmail' added to group '$groupName'."
            }
        }
    }
}

#Ends the script & disconnects when user is ready
$null = Read-Host "Job completed, any errors found will be listed above - Press Enter to Disconnect from AzureAD & Close Script"
Disconnect-AzureAD
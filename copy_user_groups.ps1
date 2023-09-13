# Import the required module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD -Credential $credential

# Prompt for the source and target user UPNs
$sourceUserUPN = Read-Host -Prompt "Enter the User Principal Name for the source user"
$targetUserUPN = Read-Host -Prompt "Enter the User Principal Name for the target user"

# Retrieve the users
$sourceUser = Get-AzureADUser -SearchString $sourceUserUPN
$targetUser = Get-AzureADUser -SearchString $targetUserUPN

# Specify the groups to exclude
$excludeGroupIds = "2a75bba6-19ed-47c7-8f51-66a3808a52a5", "4062b019-33a2-4a10-bf9f-768ff480bbba"

# Get all the groups that the source user is a member of (excluding the specified groups)
$sourceUserGroups = Get-AzureADUserMembership -ObjectId $sourceUser.ObjectId | Where-Object { $_.ObjectType -eq 'Group' -and $_.ObjectId -notin $excludeGroupIds }

foreach ($group in $sourceUserGroups) {
    # Check if the target user is already a member of the group
    $targetUserIsMember = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object { $_.ObjectId -eq $targetUser.ObjectId }

    if ($targetUserIsMember -eq $null) {
        # If the target user is not a member of the group, add them to the group
        Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $targetUser.ObjectId
        Write-Host "Added user $($targetUser.DisplayName) to group $($group.DisplayName)"
    }
    else {
        Write-Host "User $($targetUser.DisplayName) is already a member of group $($group.DisplayName)"
    }
}

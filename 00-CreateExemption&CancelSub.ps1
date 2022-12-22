
$user_object_id = "f7bb01c4-2b2b-4b76-b067-adc102c381de"
$subid = "e2af6d23-4a34-4ffc-a6b5-24b197225321"

#Login 
az login




                                            # ********** Stage 1 Create Exemption Policy using Azure CLI**********



#Create Azure Policy Exemption to allow owner role"
az policy exemption create --name "Allow Owner for Azure Decom Test AZ CLI" --display-name "Allow Owner For Azure Decom Test AZ CLI" --policy-assignment "/providers/Microsoft.Management/managementGroups/a4454629-85ac-4c26-b6be-438709073c2a/providers/Microsoft.Authorization/policyAssignments/c34560e1adab441d96fe8cf7" --exemption-category "Waiver" --scope "/subscriptions/$subid"

#Wait 5 seconds before executing the next script
Start-Sleep -Seconds 5

#Create an empty line below and above to show completion of code
Write-Output `r`n
Write-Output "********** Stage 1 Create Exemption Policy has completed **********"
Write-Output `r`n



                                            # ********** Stage 2 Grant Owner Rights using Azure CLI**********



#Create role assignment for the user but using the object-id."
az role assignment create --assignee-object-id $user_object_id --assignee-principal-type User --role owner --scope /subscriptions/$subid

#Wait 5 seconds before executing the next script
Start-Sleep -Second 5

#Create an empty line below and above to show completion of code
Write-Output `r`n
Write-Output "********** Stage 2 Granting Owner Rights has completed **********"
Write-Output `r`n



                                           # ********** Stage 3 Cancel Subscription using Azure REST API**********



# REST API will use this to get Access token
$setazContext = Set-Azcontext -subscription $subid
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

# This will call and invoke API Post to cancle subscription without deleting resources
$restUri = "https://management.azure.com/subscriptions/$subid/providers/Microsoft.Subscription/cancel?IgnoreResourceCheck=true&api-version=2019-03-01-preview"
$response = Invoke-RestMethod -Uri $restUri -Method Post -Headers $authHeader

#Wait 10 minuts before executing the next script
Start-Sleep -Second 5  # *********change to minutes when it goes to production

#Create empty line below and above to show completion of code
Write-Output `r`n
Write-Output "********** Stage 3 Canceling Subscription has completed **********"
Write-Output `r`n



                                         # ********** Stage 4 Verify Subscription Cancelation **********



# REST API will use this to get Access token
$setazContext = Set-Azcontext -subscription $subid
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

# This will call and invoke API Get to verify if subscription is disabled
$restUri = "https://management.azure.com/subscriptions/$subid/?api-version=2020-01-01"
$response = Invoke-RestMethod -Uri $restUri -Method Get -Headers $authHeader
Write-Output $response | Select displayName, id,  state

#Create empty line below and above
Write-Output `r`n
Write-Output "********** Stage 4 Verifying Subscription Cancelation has completed **********"
Write-Output `r`n
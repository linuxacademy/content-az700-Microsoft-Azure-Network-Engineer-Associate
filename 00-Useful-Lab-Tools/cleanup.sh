##############################
##############################
########## WARNING ###########
##############################
##############################

###############################
####### SCRIPT DETAILS ########
# Intended Purpose: Delete all resources in all resource groups available
# Disclaimer: This script is intended to be used only in the ACG Azure Cloud Playground/Sandbox, be mindful of your subscription context
# Message: Running this script in production environments will create a resume generating event, please be careful
# Additional Information: I have created an export command to this template in hopes to prevent unrecoverable destruction, should you accidentally misuse this script
# Exported Template Location: The scripts will be exported for each resource group to your local working directory
###############################


# Set variables
rg=`az group list --query '[].name' -o tsv`
location=`az group list --query '[].location' -o tsv`

# Iterate through all resources from a resource group defined by our rg variable
for resource in `az group list-resources --resource-group $rg --query '[].name' -o tsv`
do
    # Print out resource - uncomment for testing
    echo "Deleting $resource"

    # Export resource as an ARM template
    az resource export --resource-group $rg --name $resource --query 'properties.outputs' -o tsv > $resource.json
done
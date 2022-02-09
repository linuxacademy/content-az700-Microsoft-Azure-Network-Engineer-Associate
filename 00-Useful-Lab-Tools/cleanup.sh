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

# For loop to iterate through all resource groups in a subscription
for resource in $(az group list --query "[].{Name:name}" -o json | jq -r '.[].Name'); do
    # print out resource group name - uncomment for testing
    # echo "Resource group: $resource"

    # Export all resources in the resource group that is going to be deleted - this is your safety net should you misuse this script
    az group export --name $resource -o json > $resource.json
    echo "Exported resources in $resource to $resource.json"
    
    # Some if/then logic to provide you a way out before the deletion begins
    echo ""
    echo "WARNING: You are about delete resources!!!"
    read -p "Do you wish to proceed? (y/n) " -n 1 -r

    # Evaluate user input before proceeding with deletion
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Destroy all resources in the resource group and the resource group itself - this is where the deletion of all resource groups and their resources begins
        echo "Deleting $resource"
        az group delete --name $resource --yes
    
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        exit
    
    else
        echo "Invalid input. Exiting..."
    
    fi
    
done
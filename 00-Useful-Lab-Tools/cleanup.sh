##############################
##############################
########## WARNING ###########
##############################
##############################

###############################
####### SCRIPT DETAILS ########
# Intended Purpose: Delete all resources in a resource group
# Disclaimer: This script is intended to be used only in the ACG Azure Cloud Playground/Sandbox
# Message: Running this script in production environments will create a resume generating event, please be careful
# Additional Information: This script will export resources to ARM templates in hopes to prevent unrecoverable destruction, should you accidentally misuse this script
# Exported Template Location: The resource templates will be exported for each resource to your local working directory
###############################

##############################
##### START - VARIABLES ######
##############################

# Set variables
rg=`az group list --query '[].name' -o tsv`
location=`az group list --query '[].location' -o tsv`

##############################
##### END - VARIABLES ######
##############################


##############################
####### START - SCRIPT #######
##############################

# Iterate through all resources from a resource group defined by our rg variable
for resource in `az group list-resources --resource-group $rg --query '[].name' -o tsv`
do
    # Print out resource - uncomment for testing
    echo "Deleting $resource"

    # Export resource as an ARM template
    az resource export --resource-group $rg --name $resource --query 'properties.outputs' -o tsv > $resource.json
done

##############################
######## END - SCRIPT ########
##############################
###############################
####### SCRIPT DETAILS ########
# Intended Purpose: Setup environment for ACG Azure Cloud Sandbox
# Disclaimer: This script is intended to be used only in the ACG Azure Cloud Playground/Sandbox
# Message: To use this script for non-ACG Azure Cloud Sandbox environments
#       1.) Create your own resource group variable.
#       2.) Comment out variable in variables section.
#       3.) Uncomment below commands and assign your own resource group and location.
# rg=your-resource-group-here
# location=your-location-here
###############################

##############################
##### START - VARIABLES ######
##############################

# Get resource group and set to variable $rg
$rg = az group list --query '[].name' -o tsv

# Assign location variable to playground resource group location
$location = az group list --query '[].location' -o tsv

##############################
##### END - VARIABLES ######
##############################


##############################
####### START - SCRIPT #######
##############################

# Create Virtual Network and subnet

az network vnet create --name cake-hub-vnet --resource-group $rg --location $location --address-prefixes 10.0.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.0.1.0/24

# Create two Linux machines. We will not need to interact with the machines, just generate IP/DNS info

az vm create --resource-group $rg --name vm-1 --image Ubuntu2204 --generate-ssh-keys --public-ip-address myPublicIP-vm1 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --size Standard_B1s --no-wait

az vm create --resource-group $rg --name vm-2 --image Ubuntu2204 --generate-ssh-keys --public-ip-address myPublicIP-vm2 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --size Standard_B1s --no-wait

##############################
######## END - SCRIPT ########
##############################

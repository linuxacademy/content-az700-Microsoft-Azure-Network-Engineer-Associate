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

# Create storage account name with randomly generated characters

$storagename = -join ((48..57) + (97..122) | Get-Random -Count 12 | % { [char]$_ })

# Create storage account

az storage account create --name $storagename --resource-group $rg --location $location

# Create Virtual Network and subnets

az network vnet create --name cake-hub-vnet --resource-group $rg --location $location --address-prefixes 10.0.0.0/16 --subnet-name hub-subnet-a --subnet-prefix 10.0.1.0/24

az network vnet subnet create --name hub-subnet-b --resource-group $rg --vnet-name cake-hub-vnet --address-prefixes 10.0.2.0/24 



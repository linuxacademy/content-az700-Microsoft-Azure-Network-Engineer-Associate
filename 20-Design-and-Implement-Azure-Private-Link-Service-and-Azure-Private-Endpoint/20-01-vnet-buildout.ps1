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


# Create two Linux machines. One in each subnet

az vm create --resource-group $rg --name subnet-a-vm --image UbuntuLTS --generate-ssh-keys --public-ip-address myPublicIP-subnet-a-vm --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-a --size Standard_B1s

az vm create --resource-group $rg --name subnet-b-vm --image UbuntuLTS --generate-ssh-keys --public-ip-address myPublicIP-subnet-b-vm --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-b --size Standard_B1s


# Add rules to default NIC NSGs to allow ICMP
az network nsg rule create --resource-group $rg --nsg-name subnet-a-vmNSG --name allowIcmp --priority 110 --destination-port-ranges 0-65535 --access Allow --protocol Icmp

az network nsg rule create --resource-group $rg --nsg-name subnet-b-vmNSG --name allowIcmp --priority 110 --destination-port-ranges 0-65535 --access Allow --protocol Icmp


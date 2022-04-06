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


## SETUP MAIN HUB VNET
# Create main hub vnet
az network vnet create --name "cake-hub-vnet-01" --resource-group $rg --location $location --address-prefixes 10.60.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.60.0.0/24


## SETUP SPOKE 1 VNET
# Create spoke 1 vnet
az network vnet create --name "cake-spoke1-vnet-01" --resource-group $rg --location $location  --address-prefixes 10.120.0.0/16 --subnet-name spoke1-subnet-01 --subnet-prefix 10.120.0.0/24


## SETUP SPOKE 2 VNET
# Create spoke 2 vnet
az network vnet create --name "cake-spoke2-vnet-01" --resource-group $rg --location $location  --address-prefixes 172.32.0.0/16 --subnet-name spoke2-subnet-01 --subnet-prefix 172.32.0.0/24


## CREATE THE VM IN THE HUB VNET
az vm create --resource-group $rg --name "cake-hub-vm-01" --location $location --vnet-name "cake-hub-vnet-01" --subnet "hub-subnet-01" --image UbuntuLTS --admin-username azureuser --generate-ssh-keys

## DELETE THE NSG THAT IS CREATED WITH THE VM AND ASSOCIATED WITH THE NIC BY DEFAULT
$nicName = az vm show -n "cake-hub-vm-01" -g $rg --query 'networkProfile.networkInterfaces[0].id' -o tsv | cut -d'/' -f 9
$nsgName = az network nic show --name $nicName --resource-group $rg --query 'networkSecurityGroup.id' -o tsv | cut -d'/' -f 9
$nic = Get-AzNetworkInterface -ResourceGroupName $rg -Name $nicName
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name $nsgName
$nic.NetworkSecurityGroup = $null
$nic | Set-AzNetworkInterface
Remove-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -Force

##############################
######## END - SCRIPT ########
##############################

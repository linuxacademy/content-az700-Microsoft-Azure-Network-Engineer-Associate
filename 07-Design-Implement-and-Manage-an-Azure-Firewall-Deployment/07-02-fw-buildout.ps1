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


## CLOUD INIT FOR USERDATA SETUP OF VM
curl https://raw.githubusercontent.com/mrcloudchase/Azure/master/cloud-init.txt -o cloud-init.txt

## SETUP MAIN HUB VNET
# Create main hub vnet
az network vnet create --name cake-hub-vnet --resource-group $rg --location $location --address-prefixes 10.60.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.60.0.0/24

# Create nsg-01
az network nsg create -g $rg -n cake-hub-nsg-01

# Associate nsg-01 with subnet-01 in main hub vnet
az network vnet subnet update --resource-group $rg --vnet-name cake-hub-vnet --name hub-subnet-01 --network-security-group cake-hub-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-01 --name allowAll --priority 110 --destination-port-ranges '*' --source-address-prefixes '*' --access Allow --protocol '*'
# az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-hub-vm-01 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-hub-pip-01 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --nsg cake-hub-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-hub-vm-02 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-hub-pip-02 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --nsg cake-hub-nsg-01 --size Standard_B1s --no-wait


## CREATE FIREWALL RESOURCES
# Create hub-firewall-policy
az network firewall policy create -n hub-fw-policy-01 -g $rg --sku Premium --location $location
$fwPolicy = az network firewall policy show -n hub-fw-policy-01 -g $rg --query 'id' -o tsv

# Create AzureFirewallSubnet for hub-vnet
az network vnet subnet create --resource-group $rg --vnet-name cake-hub-vnet --name AzureFirewallSubnet --address-prefix 10.60.1.0/26

# Create cake-hub-firewall-01
az network firewall create --resource-group $rg --name cake-hub-firewall-01 --location $location --policy $fwPolicy --tier Premium

# Create Firewall PIP for cake-hub-firewall-01
az network public-ip create --resource-group $rg --name cake-hub-firewall-pip-01 --location $location --allocation-method Static --sku Standard

# Create Firewall IP Config for cake-hub-firewall-01
az network firewall ip-config create --resource-group $rg --firewall-name cake-hub-firewall-01 --name cake-hub-firewall-ip-config --public-ip-address cake-hub-firewall-pip-01 --vnet-name cake-hub-vnet

# Update the firewall to associate the IP config
az network firewall update --resource-group $rg --name cake-hub-firewall-01

# Get firewall private IP address and set to variable for reuse
$hubfwprivip = az network firewall show --resource-group $rg --name cake-hub-firewall-01 --query "ipConfigurations[0].privateIPAddress" --output tsv

# Create main Route Table that will push traffic from cake-hub-vnet associated subnets to cake-hub-firewall-01
az network route-table create --resource-group $rg --name cake-hub-fw-route-table --location $location --disable-bgp-route-propagation true

# Create the route that will push traffic from cake-hub-vnet associated subnets to cake-hub-firewall-01
az network route-table route create --resource-group $rg --route-table-name cake-hub-fw-route-table --name cake-hub-fw-route --address-prefixes 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $hubfwprivip

# Associate the route table with the cake-hub-vnet hub-subnet-01
az network vnet subnet update --resource-group $rg --vnet-name cake-hub-vnet --name hub-subnet-01 --route-table cake-hub-fw-route-table --address-prefixes 10.60.0.0/24

##############################
######## END - SCRIPT ########
##############################
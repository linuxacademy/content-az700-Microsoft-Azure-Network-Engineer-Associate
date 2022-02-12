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
$global:rg = az group list --query '[].name' -o tsv

# Assign location variable to playground resource group location
$global:location = az group list --query '[].location' -o tsv

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
az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-hub-vm-01 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-hub-pip-01 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --nsg cake-hub-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-hub-vm-02 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-hub-pip-02 --public-ip-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --nsg cake-hub-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 1 VNET
# Create spoke 1 vnet
az network vnet create --name cake-spoke1-vnet --resource-group $rg --location $location  --address-prefixes 10.120.0.0/16 --subnet-name spoke1-subnet-01 --subnet-prefix 10.120.0.0/24

# Create nsg-01
az network nsg create -g $rg -n cake-spoke1-nsg-01

# Associate nsg-01 with subnet-01 in spoke 1 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name cake-spoke1-vnet --name spoke1-subnet-01 --network-security-group cake-spoke1-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name cake-spoke1-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name cake-spoke1-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-spoke1-vm-01 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-spoke1-pip-01 --public-ip-sku Standard --vnet-name cake-spoke1-vnet --subnet spoke1-subnet-01 --nsg cake-spoke1-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-spoke1-vm-02 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-spoke1-pip-02 --public-ip-sku Standard --vnet-name cake-spoke1-vnet --subnet spoke1-subnet-01 --nsg cake-spoke1-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 2 VNET
# Create spoke 2 vnet
az network vnet create --name cake-spoke2-vnet --resource-group $rg --location $location  --address-prefixes 172.32.0.0/16 --subnet-name spoke2-subnet-01 --subnet-prefix 172.32.0.0/24

# Create nsg-01
az network nsg create -g $rg -n cake-spoke2-nsg-01

# Associate nsg-01 with subnet-01 in spoke 2 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name cake-spoke2-vnet --name spoke2-subnet-01 --network-security-group cake-spoke2-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name cake-spoke2-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name cake-spoke2-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-spoke2-vm-01 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-spoke2-pip-01 --public-ip-sku Standard --vnet-name cake-spoke2-vnet --subnet spoke2-subnet-01 --nsg cake-spoke2-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name cake-spoke2-vm-02 --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address cake-spoke2-pip-02 --public-ip-sku Standard --vnet-name cake-spoke2-vnet --subnet spoke2-subnet-01 --nsg cake-spoke2-nsg-01 --size Standard_B1s --no-wait


## SETUP REGIONAL STANDARD SKU PUBLIC LOAD BALANACER WITH A BACKEND POOL OF A VMSS AND NAT RULES FOR SSH
# Creates VMSS with Public LB of standard sku and NAT rules for SSH
az vmss create --name cake-test-vmss-01 --resource-group $rg --image UbuntuLTS --custom-data ./cloud-init.txt --lb cake-test-lb-01 --lb-sku Standard --vnet-name cake-hub-vnet --subnet hub-subnet-01 --nsg cake-hub-nsg-01 --admin-username azureuser --generate-ssh-keys

# Create lb rule to allow access for HTTP to backend webservers in VMSS
# az network lb rule create --resource-group $rg --lb-name cake-test-lb-01 --name wslbrule --protocol Tcp --frontend-ip-name loadBalancerFrontEnd --backend-pool-name cake-test-lb-01BEPool --frontend-port 80 --backend-port 80

# Create subnet in VNet for internal LB and its backend pool of VMSS
az network vnet subnet create --name hub-subnet-02 --vnet-name cake-hub-vnet --resource-group $rg --address-prefixes 10.60.1.0/24

# Create the internal LB and its backend pool of VMSS in the specified vnet and subnet without public ip address connectivity
az vmss create --name cake-test-vmss-02 --resource-group $rg --image UbuntuLTS --custom-data ./cloud-init.txt --lb cake-test-lb-02 --lb-sku Basic --vnet-name cake-hub-vnet --subnet hub-subnet-02 --public-ip-address '""' --admin-username azureuser --generate-ssh-keys

# Create nsg-02 for the hub-subnet-02 because the internal lb will be a standard sku so it is secure by default
# az network nsg create -g $rg -n cake-hub-nsg-02

# Associate nsg-02 with subnet-02 in main hub vnet
# az network vnet subnet update --resource-group $rg --vnet-name cake-hub-vnet --name hub-subnet-02 --network-security-group cake-hub-nsg-02

# Create nsg-02 rules allow SSH|HTTP from Anywhere
# az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-02 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
# az network nsg rule create --resource-group $rg --nsg-name cake-hub-nsg-02 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create lb rule to allow acces for HTTP to backend webservers in VMSS for internal lb
# az network lb rule create --resource-group $rg --lb-name cake-test-lb-02 --name wslbrule --protocol Tcp --frontend-ip-name loadBalancerFrontEnd --backend-pool-name cake-test-lb-02BEPool --frontend-port 80 --backend-port 80

## RETURN RESOURCE INFORMATION TO CLOUD SHELL
$global:extLbIp = az network public-ip show -g $rg -n cake-test-lb-01PublicIP --query 'ipAddress' -o tsv
$extLbIp
$global:extlbsshports = az network lb show -g $rg -n cake-test-lb-01 --query "inboundNatRules[*].frontendPort"
$global:intlbsshports = az network lb show -g $rg -n cake-test-lb-02 --query "inboundNatRules[*].frontendPort"
$intlbsshports
$extlbsshports
$rg
$location

##############################
######## END - SCRIPT ########
##############################


@description('The administrator username for the VMs.')
param adminUsername string

@description('The password for the admin user of the VMs')
@secure()
param adminPassword string

var location = resourceGroup().location
var hubVNetName = 'cake-hub-vnet-01'
var hubVNetMainSubnetName = 'hub-subnet-01'
var hubVNetPrefix = '10.60.0.0/16'
var hubVNetMainSubnetPrefix = '10.60.0.0/24'
var bastionName = 'cake-bastion-01'
var bastionPublicIpName = 'cake-bastion-public-ip-01'
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetPrefix = '10.60.1.0/27'
var firewallManagementSubnetName = 'AzureFirewallManagementSubnet'
var firewallManagementSubnetPrefix = '10.60.3.0/26'
var firewallSubnetName = 'AzureFirewallSubnet'
var firewallSubnetPrefix = '10.60.2.0/26'
var spokeVNetName = 'cake-spoke-vnet-01'
var spokeVNetMainSubnetName = 'spoke-subnet-01'
var spokeVNetPrefix = '10.120.0.0/16'
var spokeVNetMainSubnetPrefix = '10.120.0.0/24'
var fwName = 'cake-hub-fw'
var fwPIPPrefix = 'hub-fw-pip-'
var numOfFwPIPAddresses = 1
var azureFirewallSubnetId = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  hubVNetName,
  firewallSubnetName
)
var azureFirewallSubnetJSON = json('{"id": "${azureFirewallSubnetId}"}')
var hubVmName = 'cake-hub-vm-01'
var vmSize = 'standard_b2s'
var spokeVmName = 'cake-spoke-vm-01'
var dnsServer = '8.8.8.8'
var azureFirewallIpConfigurations = [
  for i in range(0, numOfFwPIPAddresses): {
    name: 'IpConf${i}'
    properties: {
      subnet: ((i == 0) ? azureFirewallSubnetJSON : json('null'))
      publicIPAddress: {
        id: resourceId(
          'Microsoft.Network/publicIPAddresses',
          concat(fwPIPPrefix, (i + 1))
        )
      }
    }
  }
]

resource hubVNet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: hubVNetName
  location: location
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [hubVNetPrefix]
    }
    subnets: [
      {
        name: hubVNetMainSubnetName
        properties: {
          addressPrefix: hubVNetMainSubnetPrefix
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: firewallSubnetPrefix
        }
      }
      {
        name: firewallManagementSubnetName
        properties: {
          addressPrefix: firewallManagementSubnetPrefix
        }
      }
    ]
  }
  dependsOn: []
}

resource spokeVNet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: spokeVNetName
  location: location
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: [spokeVNetPrefix]
    }
    subnets: [
      {
        name: spokeVNetMainSubnetName
        properties: {
          addressPrefix: spokeVNetMainSubnetPrefix
        }
      }
    ]
  }
  dependsOn: []
}

resource hubVNetName_peering_to_spokeVNet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: hubVNet
  name: 'peering-to-${spokeVNetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVNet.id
    }
  }
}

resource spokeVNetName_peering_to_hubVNet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: spokeVNet
  name: 'peering-to-${hubVNetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVNet.id
    }
  }
}

resource fwPIPPrefix_1 'Microsoft.Network/publicIPAddresses@2020-06-01' = [
  for i in range(0, numOfFwPIPAddresses): {
    name: concat(fwPIPPrefix, (i + 1))
    location: location
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
      publicIPAddressVersion: 'IPv4'
    }
  }
]

resource fwmgmtpublicip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'pip-fwmgmt-01'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource fw 'Microsoft.Network/azureFirewalls@2020-04-01' = {
  name: fwName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Basic'
    }
    ipConfigurations: azureFirewallIpConfigurations
    managementIpConfiguration: {
      name: 'mngipconf'
      properties: {
        publicIPAddress: {
          id: resourceId('Microsoft.Network/publicIPAddresses', fwmgmtpublicip.name)
        }
        subnet: {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets',hubVNetName,firewallManagementSubnetName)
        }
      }
    }
  }
  dependsOn: [hubVNet]
}

resource hubVmName_nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${hubVmName}-nic'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              hubVNetName,
              hubVNetMainSubnetName
            )
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: [dnsServer]
    }
  }
  dependsOn: [hubVNet]
}

resource hubVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: hubVmName
  location: location
  tags: {}
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: hubVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${hubVmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: hubVmName_nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource spokeVmName_nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${spokeVmName}-nic'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              spokeVNetName,
              spokeVNetMainSubnetName
            )
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: [dnsServer]
    }
  }
  dependsOn: [spokeVNet]
}

resource spokeVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: spokeVmName
  location: location
  tags: {}
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: spokeVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${spokeVmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: spokeVmName_nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource bastionPublicIp 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: bastionPublicIpName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: {}
}

resource bastion 'Microsoft.Network/bastionHosts@2019-09-01' = {
  name: bastionName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              hubVNetName,
              bastionSubnetName
            )
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
  tags: {}
}

$HubVnet = Get-AzVirtualNetwork -Name "cake-hub-vnet"
$Spoke2Vnet = Get-AzVirtualNetwork -Name "cake-spoke2-vnet"

Add-AzVirtualNetworkPeering -Name 'hub-spoke2' `
    -VirtualNetwork $HubVnet `
    -RemoteVirtualNetworkId $Spoke2Vnet.Id `
    -AllowForwardedTraffic `
    -AllowGatewayTransit

# Note: the spoke2-hub peering will fail because the hub network does not have a gateway to peer to.
# We are leaving the command as is for learning purposes, 
# however you will need to remove the 'UseRemoteGateways' option to successfully run it.

Add-AzVirtualNetworkPeering -Name 'spoke2-hub' `
    -VirtualNetwork $Spoke2Vnet `
    -RemoteVirtualNetworkId $HubVnet.Id `
    -AllowForwardedTraffic `
    -UseRemoteGateways

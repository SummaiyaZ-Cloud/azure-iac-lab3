@description('Admin username for the virtual machine')
param adminUsername string = 'azureuser'

@description('Admin password for the virtual machine')
@secure()
param adminPassword string

var resourceTags = {
  CostCenter: 'CloudLab'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-iac-lab3'
  location: resourceGroup().location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource webSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: 'web-subnet'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: 'app-subnet'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.2.0/24'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stcloudadminportfolio001'
  location: resourceGroup().location
  tags: resourceTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource dataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'data'
  parent: blobService
}

resource backupContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'backups'
  parent: blobService
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-iac-lab3'
  location: resourceGroup().location
  tags: resourceTags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-iac-lab3'
  location: resourceGroup().location
  tags: resourceTags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: webSubnet.id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-iac-lab3'
  location: resourceGroup().location
  tags: resourceTags
  properties: {
    hardwareProfile: {
      vmSize: 'standard_f1als_v7'
    }
    osProfile: {
      computerName: 'vm-iac-lab3'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-vm-iac-lab3'
  location: resourceGroup().location
  tags: resourceTags
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'Eastern Standard Time'
    notificationSettings: {
      status: 'Disabled'
    }
    targetResourceId: virtualMachine.id
  }
}

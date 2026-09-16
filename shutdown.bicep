resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-vm-iac-lab3'
  location: 'eastus'
  tags: {
    CostCenter: 'CloudLab'
  }
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
    targetResourceId: resourceId(
      'Microsoft.Compute/virtualMachines',
      'vm-iac-lab3'
    )
  }
}

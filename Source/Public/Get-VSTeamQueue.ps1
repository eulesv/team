function Get-VSTeamQueue {
   [CmdletBinding(DefaultParameterSetName = 'List')]
   param(
      [Parameter(ParameterSetName = 'List')]
      [string] $queueName,
      [Parameter(ParameterSetName = 'List')]
      [ValidateSet('None', 'Manage', 'Use')]
      [string] $actionFilter,
      [Parameter(ParameterSetName = 'ByID')]
      [Alias('QueueID')]
      [string] $id
   )

   DynamicParam {
      _buildProjectNameDynamicParam
   }

   process {
      # Bind the parameter to a friendly variable
      $ProjectName = $PSBoundParameters["ProjectName"]

      if ($id) {
         $resp = _callAPI -ProjectName $ProjectName -Id $id -Area distributedtask -Resource queues `
            -Version $([VSTeamVersions]::DistributedTask)

         $item = [VSTeamQueue]::new($resp, $ProjectName)

         Write-Output $item
      }
      else {
         $resp = _callAPI -ProjectName $projectName -Area distributedtask -Resource queues `
            -QueryString @{ queueName = $queueName; actionFilter = $actionFilter } -Version $([VSTeamVersions]::DistributedTask)

         $objs = @()

         foreach ($item in $resp.value) {
            $objs += [VSTeamQueue]::new($item, $ProjectName)
         }

         Write-Output $objs
      }
   }
}
function Set-VSTeamEnvironmentStatus {
   [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
   param(
      [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias('Id')]
      [int[]] $EnvironmentId,

      [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
      [int] $ReleaseId,

      [Parameter(Mandatory = $true, Position = 0)]
      [ValidateSet('canceled', 'inProgress', 'notStarted', 'partiallySucceeded', 'queued', 'rejected', 'scheduled', 'succeeded', 'undefined')]
      [Alias('EnvironmentStatus')]
      [string] $Status,

      [string] $Comment,

      [datetime] $ScheduledDeploymentTime,

      # Forces the command without confirmation
      [switch] $Force
   )

   DynamicParam {
      _buildProjectNameDynamicParam -Position 1
   }

   Process {
      Write-Debug 'Set-VSTeamEnvironmentStatus Process'

      # Bind the parameter to a friendly variable
      $ProjectName = $PSBoundParameters["ProjectName"]

      $body = ConvertTo-Json ([PSCustomObject]@{status = $Status; comment = $Comment; scheduledDeploymentTime = $ScheduledDeploymentTime})

      foreach ($item in $EnvironmentId) {
         if ($force -or $pscmdlet.ShouldProcess($item, "Set Status on Environment")) {
            Write-Debug 'Set-VSTeamEnvironmentStatus Call the REST API'

            try {
               # Call the REST API
               _callAPI -Method Patch -SubDomain vsrm -Area release -Resource "releases/$ReleaseId/environments" -projectName $ProjectName -id $item `
                  -body $body -ContentType 'application/json' -Version $([VSTeamVersions]::Release) | Out-Null

               Write-Output "Environment $item status changed to $status"
            }
            catch {
               _handleException $_
            }
         }
      }
   }
}
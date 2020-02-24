function Remove-VSTeamPolicy {
   [CmdletBinding(SupportsShouldProcess = $true)]
   param(
      [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [int[]] $Id,

      [switch] $Force
   )

   DynamicParam {
      _buildProjectNameDynamicParam -mandatory $true
   }

   Process {
      $ProjectName = $PSBoundParameters["ProjectName"]

      foreach ($item in $id) {
         if ($Force -or $pscmdlet.ShouldProcess($item, "Delete Policy")) {
            try {
               _callAPI -ProjectName $ProjectName -Method Delete -Id $item -Area policy -Resource configurations -Version $([VSTeamVersions]::Git) | Out-Null

               Write-Output "Deleted policy $item"
            }
            catch {
               _handleException $_
            }
         }
      }
   }
}
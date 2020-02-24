function Get-VSTeamExtension {
   param (
      [Parameter(ParameterSetName = 'List', Mandatory = $false)]
      [switch] $IncludeInstallationIssues,

      [Parameter(ParameterSetName = 'List', Mandatory = $false)]
      [switch] $IncludeDisabledExtensions,

      [Parameter(ParameterSetName = 'List', Mandatory = $false)]
      [switch] $IncludeErrors,

      [Parameter(ParameterSetName = 'GetById', Mandatory = $true)]
      [string] $PublisherId,

      [Parameter(ParameterSetName = 'GetById', Mandatory = $true)]
      [string] $ExtensionId
   )
   Process {

      if ($PublisherId -and $ExtensionId) {
         $resource = "extensionmanagement/installedextensionsbyname/$PublisherId/$ExtensionId"

         $resp = _callAPI -SubDomain 'extmgmt' -Resource $resource -Version $([VSTeamVersions]::ExtensionsManagement)

         $item = [VSTeamExtension]::new($resp)

         Write-Output $item
      }
      else {
         $queryString = @{}
         if ($IncludeInstallationIssues.IsPresent) {
            $queryString.includeCapabilities = $true
         }

         if ($IncludeDisabledExtensions.IsPresent) {
            $queryString.includeDisabledExtensions = $true
         }

         if ($IncludeErrors.IsPresent) {
            $queryString.includeErrors = $true
         }

         $resp = _callAPI -SubDomain 'extmgmt' -Resource 'extensionmanagement/installedextensions' -QueryString $queryString -Version $([VSTeamVersions]::ExtensionsManagement)

         $objs = @()

         foreach ($item in $resp.value) {
            $objs += [VSTeamExtension]::new($item)
         }

         Write-Output $objs
      }
   }
}
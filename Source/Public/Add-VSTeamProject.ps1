function Add-VSTeamProject {
   param(
      [parameter(Mandatory = $true)]
      [Alias('Name')]
      [string] $ProjectName,

      [string] $Description,

      [switch] $TFVC
   )

   DynamicParam {
      [VSTeamProcessCache]::timestamp = -1

      _buildProcessNameDynamicParam -ParameterName 'ProcessTemplate' -Mandatory $false
   }

   process {
      # Bind the parameter to a friendly variable
      $ProcessTemplate = $PSBoundParameters["ProcessTemplate"]

      if ($TFVC.IsPresent) {
         $srcCtrl = "Tfvc"
      }
      else {
         $srcCtrl = 'Git'
      }

      if ($ProcessTemplate) {
         Write-Verbose "Finding $ProcessTemplate id"
         $templateTypeId = (Get-VSTeamProcess -Name $ProcessTemplate).Id
      }
      else {
         # Default to Scrum Process Template
         $ProcessTemplate = 'Scrum'
         $templateTypeId = '6b724908-ef14-45cf-84f8-768b5384da45'
      }

      $body = '{"name": "' + $ProjectName + '", "description": "' + $Description + '", "capabilities": {"versioncontrol": { "sourceControlType": "' + $srcCtrl + '"}, "processTemplate":{"templateTypeId": "' + $templateTypeId + '"}}}'

      try {
         # Call the REST API
         $resp = _callAPI -Area 'projects' `
            -Method Post -ContentType 'application/json' -body $body -Version $([VSTeamVersions]::Core)

         _trackProjectProgress -resp $resp -title 'Creating team project' -msg "Name: $($ProjectName), Template: $($processTemplate), Src: $($srcCtrl)"

         # Invalidate any cache of projects.
         [VSTeamProjectCache]::timestamp = -1

         return Get-VSTeamProject $ProjectName
      }
      catch {
         _handleException $_
      }
   }
}
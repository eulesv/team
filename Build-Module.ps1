[CmdletBinding()]
param(
   #output path of the build module
   [string]$outputDir = './dist',

   # Building help is skipped by default to speed your inner loop.
   # Use this flag to include building the help
   [switch]$buildHelp,

   # By default the build will not install dependencies
   [switch]$installDep,

   # build module will be imported into session
   [switch]$ipmo,

   # run the scripts with the PS script analyzer
   [switch]$analyzeScript,

   # runs the unit tests
   [switch]$runTests,

   # can be used to filter the unit test parts that should be run
   # see also: https://github.com/pester/Pester/wiki/Invoke%E2%80%90Pester#testname-alias-name
   [string]$testName,

   # outputs the code coverage
   [switch]$codeCoverage
)

. ./Merge-File.ps1

if ($installDep.IsPresent -or $analyzeScript.IsPresent) {
   # Load the psd1 file so you can read the required modules and install them
   $manifest = Import-PowerShellDataFile .\Source\VSTeam.psd1

   # Install each module
   if ($manifest.RequiredModules) {
      $manifest.RequiredModules | ForEach-Object { if (-not (get-module $_ -ListAvailable)) { Write-Host "Installing $_"; Install-Module -Name $_ -Repository PSGallery -F -Scope CurrentUser } }
   }
}

if ([System.IO.Path]::IsPathRooted($outputDir)) {
   $output = $outputDir
}
else {
   $output = Join-Path (Get-Location) $outputDir
}

$output = [System.IO.Path]::GetFullPath($output)

Merge-File -inputFile ./Source/_functions.json -outputDir $output
Merge-File -inputFile ./Source/types/_types.json -outputDir $output
Merge-File -inputFile ./Source/Classes/_classes.json -outputDir $output
Merge-File -inputFile ./Source/formats/_formats.json -outputDir $output

# Build the help
if ($buildHelp.IsPresent) {
   Write-Output 'Creating help files'
   Push-Location
   Set-Location ./.docs
   ./gen-help.ps1
   Pop-Location
}

Write-Output 'Publishing about help files'
Copy-Item -Path ./Source/en-US -Destination "$output/" -Recurse -Force
Copy-Item -Path ./Source/VSTeam.psm1 -Destination "$output/VSTeam.psm1" -Force

Write-Output 'Updating Functions To Export'
$newValue = ((Get-ChildItem -Path "./Source/Public" -Filter '*.ps1').BaseName |
   ForEach-Object -Process { Write-Output "'$_'" }) -join ','

(Get-Content "./Source/VSTeam.psd1") -Replace ("FunctionsToExport.+", "FunctionsToExport = ($newValue)") | Set-Content "$output/VSTeam.psd1"

Write-Output "Publish complete to $output"


#reload the just build module
if ($ipmo.IsPresent -or $runTests.IsPresent) {

   #module needs to be unloaded if present
   if((Get-Module VSTeam)){
      Remove-Module VSTeam
   }

   Import-Module "$output/VSTeam.psd1" -Force
   Set-VSTeamAlias
}


#run PSScriptAnalyzer
if ($analyzeScript.IsPresent) {
   Write-Output "Starting static code analysis..."
   if ($null -eq $(Get-Module -Name PSScriptAnalyzer)) {
      Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force -Scope CurrentUser
   }

   $r = Invoke-ScriptAnalyzer -Path $output -Recurse
   $r | ForEach-Object { Write-Host "##vso[task.logissue type=$($_.Severity);sourcepath=$($_.ScriptPath);linenumber=$($_.Line);columnnumber=$($_.Column);]$($_.Message)" }
   Write-Output "Static code analysis complete."
}


# run the unit tests with Pester
if ($runTests.IsPresent) {
   if ($null -eq $(Get-Module -Name Pester)) {
      Install-Module -Name Pester -Repository PSGallery -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck
   }

   $pesterArgs = @{
      Script = '.\unit'  
      OutputFile = 'test-results.xml'
      OutputFormat = 'NUnitXml'
      Show = 'Fails'
      Strict = $true
   }

   if ($codeCoverage.IsPresent) {
      $pesterArgs.CodeCoverage = "$outputDir\*.ps1"
      $pesterArgs.CodeCoverageOutputFile = "coverage.xml"
      $pesterArgs.CodeCoverageOutputFileFormat = 'JaCoCo'
   }
   else {
      $pesterArgs.PassThru = $true
   }

   if($testName){

      $pesterArgs.TestName = $testName

      #passthru must be activated according to Pester docs
      $pesterArgs.PassThru = $true
   }

   Invoke-Pester @pesterArgs 

}
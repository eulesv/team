Write-Output 'Clearing old files'

if ((Test-Path ..\docs) -eq $false) {
   New-Item -ItemType Directory -Name ..\docs
}

Get-ChildItem ..\docs | Remove-Item

Write-Output 'Creating file index'

$sb = New-Object System.Text.StringBuilder
$files = Get-ChildItem -Path . -Filter '*-*.md'

foreach ($file in $files) {
   # Notice that I'm assigning the result of $sb.Append to $null,
   # to avoid sending any unwanted data down the pipeline.
   $null = $sb.Append("### [$($file.BaseName)]($($file.Name))`r`n`r`n")
   $null = $sb.Append("<!-- #include ""./synopsis/$($file.Name)"" -->`r`n`r`n")

   # I found files where the name of the file did not match the top most
   # title in the file. This will cause issues trying to load help for that
   # function. So test that you can find # {FileName} in the file.
   $stringToFind = "# $($file.BaseName)"
   if($null -eq $(Get-ChildItem $($file.Name) | Select-String $stringToFind)) {
      Write-Error "Title cannot be found in $($file.Name). Make sure the first header is # $($file.BaseName)`n$($File.Directory)\$File" -ErrorAction Stop
   }
}

Set-Content -Path files.md -Value $sb.ToString()

Write-Output 'Merging Markdown files'
if(-not (Get-Module Trackyon.Markdown -ListAvailable)) {
   Install-Module Trackyon.Markdown -Scope CurrentUser -Force
}

merge-markdown $PSScriptRoot $PSScriptRoot\..\docs

Write-Output 'Creating new file'

if(-not (Get-Module platyPS -ListAvailable)) {
   Install-Module platyPS -Scope CurrentUser -Force
}

New-ExternalHelp ..\docs -OutputPath ..\Source\en-US -Force

# Run again and strip header
Write-Output 'Cleaning doc files for publishing'
Get-ChildItem ..\docs | Remove-Item
Rename-Item -Path .\common\header.md -NewName header.txt
Set-Content -Path .\common\header.md -Value ''

# Docs now don't have headers
merge-markdown $PSScriptRoot $PSScriptRoot\..\docs

# Put header back
Remove-Item .\common\header.md
Rename-Item -Path .\common\header.txt -NewName header.md -Force
<!-- #include "./common/header.md" -->

# Update-VSTeamRelease

## SYNOPSIS

<!-- #include "./synopsis/Update-VSTeamRelease.md" -->

## SYNTAX

## DESCRIPTION

<!-- #include "./synopsis/Update-VSTeamRelease.md" -->

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```PowerShell
PS C:\> Set-VSTeamAccount -Account mydemos -Token $(System.AccessToken) -UseBearerToken
PS C:\> $r = Get-VSTeamRelease -ProjectName project -Id 76 -Raw
PS C:\> $r.variables.temp.value='temp'
PS C:\> Update-VSTeamRelease -ProjectName project -Id 76 -release $r
```

Changes the variable temp on the release. This can be done in one stage and read in another stage.

### -------------------------- EXAMPLE 2 --------------------------

```PowerShell
PS C:\> Set-VSTeamAccount -Account mydemos -Token $(System.AccessToken) -UseBearerToken
PS C:\> $r = Get-VSTeamRelease -ProjectName project -Id 76 -Raw
PS C:\> $r.variables | Add-Member NoteProperty temp([PSCustomObject]@{value='test'})
PS C:\> Update-VSTeamRelease -ProjectName project -Id 76 -release $r
```

Adds a variable temp to the release with a value of test.

## PARAMETERS

<!-- #include "./params/projectName.md" -->

### -Id

The id of the release to update

```yaml
Type: Int32
Required: True
Accept pipeline input: true (ByPropertyName)
```

### -Release

The updated release to save in AzD

```yaml
Type: PSCustomObject
Required: True
```

<!-- #include "./params/confirm.md" -->

<!-- #include "./params/force.md" -->

<!-- #include "./params/whatIf.md" -->

## INPUTS

## OUTPUTS

### Team.Release

## NOTES

## RELATED LINKS

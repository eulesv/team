<!-- #include "./common/header.md" -->

# Get-VSTeamBuildLog

## SYNOPSIS

<!-- #include "./synopsis/Get-VSTeamBuildLog.md" -->

## SYNTAX

## DESCRIPTION

<!-- #include "./synopsis/Get-VSTeamBuildLog.md" -->

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```PowerShell
PS C:\> Get-VSTeamBuild -Top 1 | Get-VSTeamBuildLog
```

This command displays the logs of the first build.

The pipeline operator (|) passes the build id to the Get-VSTeamBuildLog cmdlet, which
displays the logs.

## PARAMETERS

<!-- #include "./params/projectName.md" -->

<!-- #include "./params/BuildIds.md" -->

### -Index

Each task stores its logs in an array. If you know the index of a specific task you can return just its logs. If you do not provide a value all the logs are displayed.

```yaml
Type: Int32
```

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

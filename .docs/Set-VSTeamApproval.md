<!-- #include "./common/header.md" -->

# Set-VSTeamApproval

## SYNOPSIS

<!-- #include "./synopsis/Set-VSTeamApproval.md" -->

## SYNTAX

## DESCRIPTION

Set-VSTeamApproval sets the status of approval to Approved, Rejected, Pending, or ReAssigned.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```PowerShell
PS C:\> Get-VSTeamApproval | Set-VSTeamApproval
```

This command sets all pending approvals to approved.

### -------------------------- EXAMPLE 2 --------------------------

```PowerShell
PS C:\> Set-VSTeamApproval -Id 1 -Status Rejected
```

This command rejects approval with Id of 1.

## PARAMETERS

<!-- #include "./params/projectName.md" -->

### -Id

Specifies the approval IDs of the approvals to set.

```yaml
Type: Int32[]
Required: True
Accept pipeline input: true (ByPropertyName)
```

### -Status

Specifies the status to set for the approval. The acceptable values for this parameter are:

- Approved
- Rejected
- Pending
- ReAssigned

```yaml
Type: String
Required: True
Default value: Approved
```

### -Approver

Specifies the user to whom the approval has been re-assigned to Alias of the user chuckreinhart@outlook.com, for example.

```yaml
Type: String
```

### -Comment

Specifies the comment to be stored with this approval.

```yaml
Type: String
```

<!-- #include "./params/force.md" -->

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

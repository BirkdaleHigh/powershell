<#Param(
    $SearchBase = "OU=Year R,OU=Students,OU=Users,OU=BHS,DC=BHS,DC=INTERNAL",
    $MDLGroup = "Year 10 | Mr J Bennett",
    $Path = 'export.csv'
)

get-aduser -Filter * -SearchBase $SearchBase -Properties 'givenname','surname',SAMAccountname |
    Sort-Object Surname |
    select @{n='1 - Action';e={'A'}},
        @{n='2 - User ID - do not edit (DL use only)';e={''}},
        @{n='3 - User Type';e={'S'}},
        @{n='4 - User Name';e={'CA'+$_.samaccountname}},
        @{n='5 - Passwword';e={Get-Random -Minimum 100000 -Maximum 999999}},
        @{n='6 - Title';e={''}},
        @{n='7 - First name';e={$_.givenname}},
        @{n='8 - Middle name';e={''}},
        @{n='9 - Last name';e={$_.surname}},
        @{n='10 - DOB';e={''}},
        @{n='11 - Sex';e={''}},
        @{n='12 - UPN';e={''}},
        @{n='13 - email';e={''}},
        @{n=$MDLGroup;e={'Yes'}} |
        ConvertTo-Csv -NoTypeInformation |
        out-file $Path
        #>
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Validate-User
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Action
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("A", "E", "D")]
        [Alias('Action')]
        [string]
        ${1 - Action} = "A"

        , # User ID - do not edit (DL use only)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        ${2 - User ID - do not edit (DL use only)}

        , # S (for ‘student’) or TA (for Teacher)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("S", "TA")]
        [string]
        ${3 - User Type} = "S"

        , # User Name
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [ValidateLength(6,25)]
        [Alias('SamAccountName')]
        [string]
        ${4 - User Name}

        , # User ID - do not edit (DL use only)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        ${5 - Passwword} = (Get-Random -Minimum 1000 -Maximum 9999)
    )
    Process
    {
        New-Object -TypeName pscustomobject -Property $PSBoundParameters
    }
}

using module "./builders/win-node-builder.psm1"
using module "./builders/nix-node-builder.psm1"

<#
.SYNOPSIS
Generate Node.js artifact.

.DESCRIPTION
Main script that creates instance of NodeBuilder and builds of Node.js using specified parameters.

.PARAMETER Version
Required parameter. The version with which Node.js will be built.

.PARAMETER Architecture
Optional parameter. The architecture with which Node.js will be built. Using x64 by default.

.PARAMETER Platform
Required parameter. The platform for which Node.js will be built.

#>

param(
    [Parameter (Mandatory=$true)][Version] $Version,
    [Parameter (Mandatory=$true)][string] $Platform,
    [string] $Architecture = "x64"
)

Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "nix-helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "win-helpers.psm1") -DisableNameChecking

function Get-NodeBuilder {
    <#
    .SYNOPSIS
    Wrapper for class constructor to simplify importing NodeBuilder.

    .DESCRIPTION
    Create instance of NodeBuilder with specified parameters.

    .PARAMETER Version
    The version with which Node.js will be built.

    .PARAMETER Platform
    The platform for which Node.js will be built.

    .PARAMETER Architecture
    The architecture with which Node.js will be built.

    #>

    param (
        [version] $Version,
        [string] $Architecture,
        [string] $Platform
    )

    $Platform = $Platform.ToLower()  
    if ($Platform -match 'win32') {
        $builder = [WinNodeBuilder]::New($Version, $Platform, $Architecture)
    } elseif (($Platform -match 'linux') -or ($Platform -match 'darwin')) {
        $builder = [NixNodeBuilder]::New($Version, $Platform, $Architecture)
    } else {
        Write-Host "##vso[task.logissue type=error;] Invalid platform: $Platform"
        exit 1
    }

    return $builder
}

### Create Node.js builder instance, and build artifact
$Builder = Get-NodeBuilder -Version $Version -Platform $Platform -Architecture $Architecture
$Builder.Build()

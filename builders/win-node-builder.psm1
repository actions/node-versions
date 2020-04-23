using module "./builders/node-builder.psm1"

class WinNodeBuilder : NodeBuilder {
    <#
    .SYNOPSIS
    Ubuntu Node.js builder class.

    .DESCRIPTION
    Contains methods that required to build Ubuntu Node.js artifact from sources. Inherited from base NixNodeBuilder.

    .PARAMETER platform
    The full name of platform for which Node.js should be built.

    .PARAMETER version
    The version of Node.js that should be built.

    #>

    [string] $InstallationTemplateName
    [string] $InstallationScriptName
    [string] $OutputArtifactName

    WinNodeBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture
    ) : Base($version, $platform, $architecture) {
        $this.InstallationTemplateName = "win-setup-template.ps1"
        $this.InstallationScriptName = "setup.ps1"
        $this.OutputArtifactName = "tool.7z"
    }

    [uri] GetBinariesUri() {
        <#
        .SYNOPSIS
        Get base Node.js URI and return complete URI for Node.js installation executable.
        #>

        $base = $this.GetBaseUri()
        return "${base}/v$($this.Version)/node-v$($this.Version)-win-$($this.Architecture).7z"
    }

    [void] ExtractBinaries($archivePath) {
        Extract-7ZipArchive -ArchivePath $archivePath -OutputDirectory $this.ArtifactLocation
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Node.js artifact installation script based on specified template.
        #>

        $installationScriptLocation = New-Item -Path $this.ArtifactLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName
        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw

        $variablesToReplace = @{
            "{{__VERSION__}}" = $this.Version;
            "{{__ARCHITECTURE__}}" = $this.Architecture;
        }

        $variablesToReplace.keys | ForEach-Object { $installationTemplateContent = $installationTemplateContent.Replace($_, $variablesToReplace[$_]) }
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation
        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }
}

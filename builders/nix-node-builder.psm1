using module "./node-builder.psm1"

class NixNodeBuilder : NodeBuilder {
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

    NixNodeBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture
    ) : Base($version, $platform, $architecture) {
        $this.InstallationTemplateName = "nix-setup-template.sh"
        $this.InstallationScriptName = "setup.sh"
        $this.OutputArtifactName = "node-$Version-$Platform-$Architecture.tar.gz"
    }

    [uri] GetBinariesUri() {
        <#
        .SYNOPSIS
        Get base Node.js URI and return complete URI for Node.js installation executable.
        #>

        $base = $this.GetBaseUri()
        return "${base}/v$($this.Version)/node-v$($this.Version)-$($this.Platform)-$($this.Architecture).tar.gz"
    }

    [void] ExtractBinaries($archivePath) {
        Extract-TarArchive -ArchivePath $archivePath -OutputDirectory $this.WorkFolderLocation
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Node.js artifact installation script based on template specified in InstallationTemplateName property.
        #>

        $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName

        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw
        $installationTemplateContent = $installationTemplateContent -f $this.Version.ToString(3), $this.Architecture
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation

        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }

    [void] ArchiveArtifact() {
        $OutputPath = Join-Path $this.ArtifactFolderLocation $this.OutputArtifactName
        Create-TarArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutputPath
    }
}

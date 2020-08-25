class NodeBuilder {
    <#
    .SYNOPSIS
    Base Node.js builder class.

    .DESCRIPTION
    Base Node.js builder class that contains general builder methods.

    .PARAMETER Version
    The version of Node.js that should be built.

    .PARAMETER Platform
    The platform of Node.js that should be built.

    .PARAMETER Architecture
    The architecture with which Node.js should be built.

    .PARAMETER TempFolderLocation
    The location of temporary files that will be used during Node.js package generation.

    .PARAMETER WorkFolderLocation
    The location of installation files.

    .PARAMETER ArtifactFolderLocation
    The location of generated Node.js artifact.

    .PARAMETER InstallationTemplatesLocation
    The location of installation script template. Using "installers" folder from current repository.

    #>

    [version] $Version
    [string] $Platform
    [string] $Architecture
    [string] $TempFolderLocation
    [string] $WorkFolderLocation
    [string] $ArtifactFolderLocation
    [string] $InstallationTemplatesLocation

    NodeBuilder ([version] $version, [string] $platform, [string] $architecture) {
        $this.Version = $version
        $this.Platform = $platform
        $this.Architecture = $architecture

        $this.TempFolderLocation = [IO.Path]::GetTempPath()
        $this.WorkFolderLocation = Join-Path $env:RUNNER_TEMP "binaries"
        $this.ArtifactFolderLocation = Join-Path $env:RUNNER_TEMP "artifact"

        $this.InstallationTemplatesLocation = Join-Path -Path $PSScriptRoot -ChildPath "../installers"
    }

    [uri] GetBaseUri() {
        <#
        .SYNOPSIS
        Return base URI for Node.js binaries.
        #>

        return "https://nodejs.org/download/release"
    }

    [string] Download() {
        <#
        .SYNOPSIS
        Download Node.js binaries into artifact location.
        #>

        $binariesUri = $this.GetBinariesUri()
        $targetFilename = [IO.Path]::GetFileName($binariesUri)
        $targetFilepath = Join-Path -Path $this.TempFolderLocation -ChildPath $targetFilename

        Write-Debug "Download binaries from $binariesUri to $targetFilepath"
        try {
            (New-Object System.Net.WebClient).DownloadFile($binariesUri, $targetFilepath)
        } catch {
            Write-Host "Error during downloading file from '$binariesUri'"
            exit 1
        }

        Write-Debug "Done; Binaries location: $targetFilepath"
        return $targetFilepath
    }

    [void] Build() {
        <#
        .SYNOPSIS
        Generates Node.js artifact from downloaded binaries.
        #>

        Write-Host "Create WorkFolderLocation and ArtifactFolderLocation folders"
        New-Item -Path $this.WorkFolderLocation -ItemType "directory"
        New-Item -Path $this.ArtifactFolderLocation -ItemType "directory"

        Write-Host "Download Node.js $($this.Version) [$($this.Architecture)] executable..."
        $binariesArchivePath = $this.Download()

        Write-Host "Unpack binaries to target directory"
        $this.ExtractBinaries($binariesArchivePath)

        Write-Host "Create installation script..."
        $this.CreateInstallationScript()

        Write-Host "Archive artifact"
        $this.ArchiveArtifact()
    }
}

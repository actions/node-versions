using module "./node-builder.psm1"

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
        $this.OutputArtifactName = "node-$Version-$Platform-$Architecture.7z"
    }




   [uri] GetBinariesUri() {
    <#
    .SYNOPSIS
    Get base Node.js URI and return complete URI for Node.js installation executable.
    #>

    $base = $this.GetBaseUri()
    $uri = "${base}/v$($this.Version)/node-v$($this.Version)-win-$($this.Architecture).7z"

    # Check if the package exists
    try {
        $response = Invoke-WebRequest -Uri $uri -Method Head -ErrorAction Stop

        # If the request was successful and the status code is 200, return the URI
        if ($response.StatusCode -eq 200) {
            return $uri
        } else {
            Write-Host "Skipping build as the binary does not exist."
            return $null
        }
    } catch {
        Write-Host "Skipping build as the binary does not exist."
        return $null
    }
}
   
    [void] ExtractBinaries($archivePath) {
        $extractTargetDirectory = Join-Path $this.TempFolderLocation "tempExtract"
        Extract-SevenZipArchive -ArchivePath $archivePath -OutputDirectory $extractTargetDirectory
        $nodeOutputPath = Get-Item $extractTargetDirectory\* | Select-Object -First 1 -ExpandProperty Fullname
        Move-Item -Path $nodeOutputPath\* -Destination $this.WorkFolderLocation -Force
      }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Node.js artifact installation script based on specified template.
        #>

        $installationScriptLocation = $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File -Force
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

    [void] ArchiveArtifact() {
        $OutputPath = Join-Path $this.ArtifactFolderLocation $this.OutputArtifactName
        Create-SevenZipArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutputPath -ArchiveType "7z"
    }
}

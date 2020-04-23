<#
.SYNOPSIS
Unpack *.tar file
#>
function Extract-TarArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [Parameter(Mandatory=$true)]
        [String]$OutputDirectory
    )

    Write-Debug "Extract $ArchivePath to $OutputDirectory"
    tar -C $OutputDirectory -xzf $ArchivePath --strip 1
}

function Create-TarArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$SourceFolder,
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [string]$CompressionType = "gz"
    )

    $CompressionTypeArgument = If ([string]::IsNullOrWhiteSpace($CompressionType)) { "" } else { "--${CompressionType}" }

    Push-Location $SourceFolder
    Write-Debug "tar -c $CompressionTypeArgument -f $ArchivePath ."
    tar -c $CompressionTypeArgument -f $ArchivePath .
    Pop-Location
}
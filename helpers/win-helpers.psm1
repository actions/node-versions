<#
.SYNOPSIS
Unpack *.7z file
#>
function Extract-SevenZipArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [Parameter(Mandatory=$true)]
        [String]$OutputDirectory
    )

    Write-Debug "Extract $ArchivePath to $OutputDirectory"
    7z x $ArchivePath -o"$OutputDirectory" -y | Out-Null
}

function Create-SevenZipArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$SourceFolder,
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [String]$ArchiveType = "zip",
        [String]$CompressionLevel = 5
    )

    $ArchiveTypeArgument = "-t${ArchiveType}"
    $CompressionLevelArgument = "-mx=${CompressionLevel}"
    
    Push-Location $SourceFolder
    Write-Debug "7z a $ArchiveTypeArgument $CompressionLevelArgument $ArchivePath @$SourceFolder"
    7z a $ArchiveTypeArgument $CompressionLevelArgument $ArchivePath $SourceFolder\*
    Pop-Location
}
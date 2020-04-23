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
        [String]$ArchiveType = "zip"
    )

    $ArchiveTypeArgument = "-t${ArchiveType}"

    Push-Location $SourceFolder
    7z a $ArchiveTypeArgument $ArchivePath *.* -r
    Pop-Location
}
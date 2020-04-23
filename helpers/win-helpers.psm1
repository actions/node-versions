<#
.SYNOPSIS
Unpack *.7z file
#>
function Unpack-7ZipArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [Parameter(Mandatory=$true)]
        [String]$OutputDirectory
    )

    Write-Debug "Unpack $ArchivePath to $OutputDirectory"
    7z x $ArchivePath -o$OutputDirectory

}
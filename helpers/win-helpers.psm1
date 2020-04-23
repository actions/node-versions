<#
.SYNOPSIS
Unpack *.7z file
#>
function Extract-7ZipArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [Parameter(Mandatory=$true)]
        [String]$OutputDirectory
    )

    Write-Debug "Extract $ArchivePath to $OutputDirectory"
    Write-Host "7z x $ArchivePath -o$OutputDirectory"
    7z x $ArchivePath -o$OutputDirectory
}
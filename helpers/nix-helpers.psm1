<#
.SYNOPSIS
Unpack *.tar file
#>
function Unpack-TarArchive {
    param(
        [Parameter(Mandatory=$true)]
        [String]$ArchivePath,
        [Parameter(Mandatory=$true)]
        [String]$OutputDirectory
    )

    Write-Debug "Unpack $ArchivePath to $OutputDirectory"
    tar -C $OutputDirectory -xzf $ArchivePath

}
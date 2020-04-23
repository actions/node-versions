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
$ErrorActionPreference = "Stop"
[Version]$Version = "{{__VERSION__}}"
[string]$Architecture = "{{__ARCHITECTURE__}}"
$ArchiveFileName = "tool.7z"
$TempDirectory = Join-Path $env:TEMP "Node"

$ToolcacheRoot = $env:AGENT_TOOLSDIRECTORY
if ([string]::IsNullOrEmpty($ToolcacheRoot)) {
    # GitHub images don't have `AGENT_TOOLSDIRECTORY` variable
    $ToolcacheRoot = $env:RUNNER_TOOL_CACHE
}
$NodeToolcachePath = Join-Path -Path $ToolcacheRoot -ChildPath "node"
$NodeToolcacheVersionPath = Join-Path -Path $NodeToolcachePath -ChildPath $Version.ToString()
$NodeToolcacheArchitecturePath = Join-Path $NodeToolcacheVersionPath $Architecture

Write-Host "Check if Node.js hostedtoolcache folder exist..."
if (-not (Test-Path $NodeToolcachePath)) {
    New-Item -ItemType Directory -Path $NodeToolcachePath | Out-Null
}

Write-Host "Delete Node.js $Version if installed"
if (Test-Path $NodeToolcacheVersionPath) {
    Remove-Item $NodeToolcachePath -Recurse -Force | Out-Null
}

Write-Host "Create Node.js $Version folder"
if (-not (Test-Path $NodeToolcacheArchitecturePath)) {
    New-Item -ItemType Directory -Path $NodeToolcacheArchitecturePath | Out-Null
}

Write-Host "Copy Node.js binaries to hostedtoolcache folder"
Copy-Item -Path $ArchiveFileName -Destination $NodeToolcacheArchitecturePath

Set-Location $NodeToolcacheArchitecturePath
Write-Host "Unzip Node.js to $NodeToolcacheArchitecturePath"
7z.exe x $ArchiveFileName -o"$TempDirectory" -y | Out-Null
$NodeInnerFolder = Get-Item -Path "$TempDirectory\node-*" | Select-Object -First 1
Get-ChildItem $NodeInnerFolder | Move-Item -Destination $NodeToolcacheArchitecturePath
Write-Host "Node.js unzipped successfully"

Remove-Item $ArchiveFileName -Force | Out-Null

Write-Host "Create complete file"
New-Item -ItemType File -Path $NodeToolcacheVersionPath -Name "$Architecture.complete" | Out-Null
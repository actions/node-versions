param (
    [Version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

function Get-UseNodeLogs {
    $homeDir = $env:HOME
    if ([string]::IsNullOrEmpty($homeDir)) {
        # GitHub Windows images don't have `HOME` variable
        $homeDir = $env:HOMEDRIVE
    }

    $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/*/_diag/pages" -Resolve

    $useNodeLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
        $logContent = Get-Content $_.Fullname -Raw
        return $logContent -match "setup-node@v"
    } | Select-Object -First 1
    return $useNodeLogFile.Fullname
}

Describe "Node.js" {
    It "is available" {
        "node --version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression "node --version"
        $versionOutput | Should -Match $Version
    }

    It "is used from tool-cache" {
        $nodePath = (Get-Command "node").Path
        $nodePath | Should -Not -BeNullOrEmpty
        $expectedPath = Join-Path -Path $env:AGENT_TOOLSDIRECTORY -ChildPath "node"
        $nodePath.startsWith($expectedPath) | Should -BeTrue -Because "'$nodePath' is not started with '$expectedPath'"
    }

    It "cached version is used without downloading" {
        # Analyze output of previous steps to check if Node.js was consumed from cache or downloaded
        $useNodeLogFile = Get-UseNodeLogs
        $useNodeLogFile | Should -Exist
        $useNodeLogContent = Get-Content $useNodeLogFile -Raw
        $useNodeLogContent | Should -Match "Found in cache"
    }

    It "Run simple code" {
        "node ./simple-test.js" | Should -ReturnZeroExitCode
    }
}
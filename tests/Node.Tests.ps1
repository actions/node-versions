param (
    [Version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/packages-generation/pester-extensions.psm1")

function Get-UseNodeLogs {
    $logsFolderPath = Join-Path -Path $env:AGENT_HOMEDIRECTORY -ChildPath "_diag" | Join-Path -ChildPath "pages"

    $useNodeLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
        $logContent = Get-Content $_.Fullname -Raw
        return $logContent -match "Use Node"
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
        $useNodeLogContent | Should -Match "Found tool in cache"
    }

    It "Run simple code" {
        "node ./simple-test.js" | Should -ReturnZeroExitCode
    }
}
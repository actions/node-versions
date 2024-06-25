Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

BeforeAll {
    function Get-UseNodeLogs {
    # GitHub Windows images don't have `HOME` variable
    $homeDir = $env:HOME ?? $env:HOMEDRIVE
    $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/*/_diag/pages" -Resolve

    if (Test-Path -Path $logsFolderPath) {
        $useNodeLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
            $logContent = Get-Content $_.Fullname -Raw
            return $logContent -match "setup-node@v"
        } | Select-Object -First 1
        return $useNodeLogFile.Fullname
    } else {
        
        return $null
    }
}
}

Describe "Node.js" {
    It "is available" {
        "node --version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression "node --version"
        $versionOutput | Should -Match $env:VERSION
    }

    It "is used from tool-cache" {
        $nodePath = (Get-Command "node").Path
        $nodePath | Should -Not -BeNullOrEmpty
        
        # GitHub Windows images don't have `AGENT_TOOLSDIRECTORY` variable
        $toolcacheDir = $env:AGENT_TOOLSDIRECTORY ?? $env:RUNNER_TOOL_CACHE
        $expectedPath = Join-Path -Path $toolcacheDir -ChildPath "node"
        $nodePath.startsWith($expectedPath) | Should -BeTrue -Because "'$nodePath' is not started with '$expectedPath'"
    }

    It "cached version is used without downloading" {
    $useNodeLogFile = Get-UseNodeLogs
    if ($useNodeLogFile -eq $null) {
        Skip "Log file does not exist"
    } else {
        $useNodeLogFile | Should -Exist
        $useNodeLogContent = Get-Content $useNodeLogFile -Raw
        $useNodeLogContent | Should -Match "Found in cache"
    }
}
    It "Run simple code" {
        "node ./simple-test.js" | Should -ReturnZeroExitCode
    }
}

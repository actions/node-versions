Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

BeforeAll {
    function Get-UseNodeLogs {
        # GitHub Windows images don't have `HOME` variable
        $homeDir = $env:HOME ?? $env:HOMEDRIVE
        $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/*/_diag/pages" -Resolve

        $useNodeLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
            $logContent = Get-Content $_.Fullname -Raw
            return $logContent -match "setup-node@v"
        } | Select-Object -First 1
        return $useNodeLogFile.Fullname
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

    BeforeAll {
    Write-Host "Architecture: $($env:PROCESSOR_ARCHITECTURE)"
    Write-Host "OS: $($env:OS)"
    }

    It "cached version is used without downloading" {
        # Check the architecture and OS before running the test
        if (($env:PROCESSOR_ARCHITECTURE -ne 'ARM64') -or (($env:OS -ne 'Windows_NT') -and ($env:OS -ne 'Linux'))) {
            # Analyze output of previous steps to check if Node.js was consumed from cache or downloaded
            $useNodeLogFile = Get-UseNodeLogs
            $useNodeLogFile | Should -Exist
            $useNodeLogContent = Get-Content $useNodeLogFile -Raw
            $useNodeLogContent | Should -Match "Found in cache"
        } else {
            # Skip the test for arm64 on Windows and Linux
            Set-ItResult -Skipped -Because "Skipping this test for arm64 on Windows and Linux"
        }
    }


    It "Run simple code" {
        "node ./simple-test.js" | Should -ReturnZeroExitCode
    }
}

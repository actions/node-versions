Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

BeforeAll {
    function Get-UseNodeLogs {
        # Determine if the current environment is Windows or Linux
        $isWindows = $PSVersionTable.PSVersion.Platform -eq "Win32NT"
        $isArm64 = $env:PROCESSOR_ARCHITECTURE -eq "ARM64"

        # For Windows, use HOMEDRIVE if HOME is not available
        # For Linux, use HOME directly
        $homeDir = if ($isWindows) { $env:HOME ?? $env:HOMEDRIVE } else { $env:HOME }

        # Check if the OS is Windows ARM64 or Linux ARM64 and set the logs folder path accordingly
        if ($isWindows -and $isArm64) {
            $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/_diag/pages" -Resolve
        } elseif (-not $isWindows -and $isArm64) {
            $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/_diag/pages" -Resolve
        } else {
            throw "Unsupported OS or architecture."
        }

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

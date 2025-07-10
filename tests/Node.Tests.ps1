Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")



Describe "Node.js" {

    BeforeAll {
        function Get-UseNodeLogs {
            # GitHub Windows images don't have `HOME` variable
            $homeDir = $env:HOME ?? $env:HOMEDRIVE
            
            $possiblePaths = @(
                Join-Path -Path $homeDir -ChildPath "actions-runner/cached/_diag/pages"
                Join-Path -Path $homeDir -ChildPath "runners/*/_diag/pages"
            )
            
            $logsFolderPath = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
            $resolvedPath = Resolve-Path -Path $logsFolderPath -ErrorAction SilentlyContinue

            if ($resolvedPath -and -not [string]::IsNullOrEmpty($resolvedPath.Path) -and (Test-Path $resolvedPath.Path)) {                
                $useNodeLogFile = Get-ChildItem -Path $resolvedPath | Where-Object {
                            $logContent = Get-Content $_.Fullname -Raw
                            return $logContent -match "setup-node@v"                     
                    } | Select-Object -First 1                
                
              # Return the file name if a match is found
                if ($useNodeLogFile) {
                    return $useNodeLogFile.FullName
                } else {
                    Write-Error "No matching log file found in the specified path: $($resolvedPath.Path)"
                }
            } else {
                Write-Error "The provided logs folder path is null, empty, or does not exist: $logsFolderPath"
            }
        }
    }
    
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

       if ($env:RUNNER_TYPE -eq "self-hosted") {
            # Get the installed version of Node.js
            $nodeVersion = Invoke-Expression "node --version"
            # Check if Node.js is installed
            $nodeVersion | Should -Not -BeNullOrEmpty
            # Check if the installed version of Node.js is the expected version
            $nodeVersion | Should -Match $env:VERSION
        }else {
            # Analyze output of previous steps to check if Node.js was consumed from cache or downloaded
            $useNodeLogFile = Get-UseNodeLogs
            $useNodeLogFile | Should -Exist
            $useNodeLogContent = Get-Content $useNodeLogFile -Raw
            $useNodeLogContent | Should -Match "Found in cache"
        } 
    }
    
    It "Run simple code" {
        "node ./simple-test.js" | Should -ReturnZeroExitCode
    }
}

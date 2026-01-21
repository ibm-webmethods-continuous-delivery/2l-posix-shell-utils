<#
.SYNOPSIS
    Runs all containerized POSIX Shell Utils tests with summary reporting.

.DESCRIPTION
    Executes tests across multiple container images (UBI, Alpine, Debian) and shells,
    then presents a summary table showing failed test counts per image/shell combination.

.OUTPUTS
    Sets $TestResult variable to "OK" or "FAILED"
    Displays summary table of test results
#>

[CmdletBinding()]
param()

# Initialize result tracking
$script:TestResult = "OK"
$script:ResultMatrix = @{}

# Define test configurations
$testConfigs = @(
    @{
        Name = "UBI"
        Path = "ubi"
        Shells = @("sh", "bash")
    },
    @{
        Name = "Alpine"
        Path = "alpine"
        Shells = @("bash", "dash", "ash")
    },
    @{
        Name = "Debian"
        Path = "debian"
        Shells = @("sh", "bash", "dash")
    }
)

function Parse-TestOutput {
    param(
        [string]$Output,
        [string]$ImageName,
        [string]$ShellType
    )
    
    $failCount = 0
    
    # Look for test failure patterns in output
    # Common patterns: "FAIL:", "failed", "X tests failed", etc.
    $lines = $Output -split "`n"
    
    foreach ($line in $lines) {
        # Check for explicit failure messages
        if ($line -match "(\d+)\s+failed" -or $line -match "FAIL.*?(\d+)") {
            $failCount += [int]$matches[1]
        }
        # Check for individual test failures
        elseif ($line -match "^\s*FAIL:" -or $line -match "^\s*✗" -or $line -match "^\s*\[FAIL\]") {
            $failCount++
        }
    }
    
    # Check exit code pattern in output
    if ($Output -match "exit code:\s*(\d+)" -and $matches[1] -ne "0") {
        if ($failCount -eq 0) {
            $failCount = 1  # At least one failure if non-zero exit
        }
    }
    
    return $failCount
}

function Run-ImageTests {
    param(
        [hashtable]$Config
    )
    
    $imageName = $Config.Name
    $imagePath = $Config.Path
    $shells = $Config.Shells
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Testing: $imageName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Initialize result matrix for this image
    if (-not $script:ResultMatrix.ContainsKey($imageName)) {
        $script:ResultMatrix[$imageName] = @{}
    }
    
    # Change to image directory
    $originalPath = Get-Location
    Set-Location (Join-Path $PSScriptRoot $imagePath)
    
    try {
        # Run general test
        Write-Host "`nRunning general tests..." -ForegroundColor Yellow
        $output = docker compose run --rm test 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
        
        # Test each shell individually
        foreach ($shell in $shells) {
            Write-Host "`nTesting with $shell..." -ForegroundColor Yellow
            
            $shellOutput = docker compose run --rm -e SHELL_TYPE=$shell shell-test 2>&1 | Out-String
            $shellExitCode = $LASTEXITCODE
            
            # Parse output for failure count
            $failCount = Parse-TestOutput -Output $shellOutput -ImageName $imageName -ShellType $shell
            
            # If exit code is non-zero but no failures detected, count as 1 failure
            if ($shellExitCode -ne 0 -and $failCount -eq 0) {
                $failCount = 1
            }
            
            # Store result
            $script:ResultMatrix[$imageName][$shell] = $failCount
            
            # Update overall result
            if ($failCount -gt 0) {
                $script:TestResult = "FAILED"
            }
            
            # Show brief status
            if ($failCount -eq 0) {
                Write-Host "  ✓ $shell : PASSED" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $shell : $failCount failure(s)" -ForegroundColor Red
            }
        }
        
    } finally {
        Set-Location $originalPath
    }
}

# Main execution
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "POSIX Shell Utils - Comprehensive Container Testing" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# Run tests for each image
foreach ($config in $testConfigs) {
    Run-ImageTests -Config $config
}

# Display summary table
Write-Host "`n`n=====================================================" -ForegroundColor Cyan
Write-Host "TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# Collect all unique shells
$allShells = $testConfigs | ForEach-Object { $_.Shells } | Select-Object -Unique | Sort-Object

# Build table header
$headerFormat = "{0,-12}"
$header = $headerFormat -f "Image"
foreach ($shell in $allShells) {
    $header += " | {0,6}" -f $shell
}
Write-Host "`n$header" -ForegroundColor White
Write-Host ("-" * ($header.Length)) -ForegroundColor Gray

# Build table rows
foreach ($config in $testConfigs) {
    $imageName = $config.Name
    $row = $headerFormat -f $imageName
    
    foreach ($shell in $allShells) {
        if ($script:ResultMatrix[$imageName].ContainsKey($shell)) {
            $failCount = $script:ResultMatrix[$imageName][$shell]
            if ($failCount -eq 0) {
                $row += " | " + ("{0,6}" -f "OK")
            } else {
                $row += " | " + ("{0,6}" -f $failCount)
            }
        } else {
            $row += " | " + ("{0,6}" -f "N/A")
        }
    }
    
    # Color code the row based on results
    $hasFailures = $script:ResultMatrix[$imageName].Values | Where-Object { $_ -gt 0 }
    if ($hasFailures) {
        Write-Host $row -ForegroundColor Red
    } else {
        Write-Host $row -ForegroundColor Green
    }
}

# Display overall result
Write-Host "`n=====================================================" -ForegroundColor Cyan
if ($script:TestResult -eq "OK") {
    Write-Host "OVERALL RESULT: OK - All tests passed!" -ForegroundColor Green
    $exitCode = 0
} else {
    Write-Host "OVERALL RESULT: FAILED - Some tests failed!" -ForegroundColor Red
    $exitCode = 1
}
Write-Host "=====================================================" -ForegroundColor Cyan

# Export result variable for external use
$global:TestResult = $script:TestResult

# Return exit code
exit $exitCode

# Made with Bob

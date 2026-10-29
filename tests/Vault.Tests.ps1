<#
.SYNOPSIS
    Citadel Vault & Doctrine Automated Test Suite
.DESCRIPTION
    Validates Markdown contract compliance, PowerShell AST syntax integrity across
    all Check, Apply, and Rollback code blocks, and Doctrine synchronization.
    Runs seamlessly standalone or within CI pipelines.
#>

[CmdletBinding()]
param()

$repoRoot = Split-Path -Parent $PSScriptRoot
$vaultPath = Join-Path $repoRoot "directives\vault"
$doctrinePath = Join-Path $repoRoot "directives\hardening-doctrine.md"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " CITADEL VAULT & DOCTRINE INTEGRITY TEST SUITE" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$failedTests = 0
$passedTests = 0

function Assert-Test {
    param(
        [string]$Name,
        [bool]$Condition,
        [string]$Details = ""
    )
    if ($Condition) {
        Write-Host "  [+] PASS: $Name" -ForegroundColor Green
        $script:passedTests++
    } else {
        Write-Host "  [-] FAIL: $Name" -ForegroundColor Red
        if ($Details) {
            Write-Host "      Reason: $Details" -ForegroundColor Yellow
        }
        $script:failedTests++
    }
}

# 1. Doctrine Parity Tests
Write-Host "`n[Context] Doctrine Synchronization" -ForegroundColor Magenta
Assert-Test -Name "hardening-doctrine.md exists" -Condition (Test-Path $doctrinePath)

$doctrineContent = Get-Content $doctrinePath -Raw
$vaultFiles = Get-ChildItem -Path (Join-Path $vaultPath "*.md") | Sort-Object Name

Assert-Test -Name "Vault contains 22 active security vectors" -Condition ($vaultFiles.Count -eq 22) -Details "Found $($vaultFiles.Count) files"

foreach ($file in $vaultFiles) {
    $pattern = "\[$($file.Name)\]\(vault/$($file.Name)\)"
    $isIndexed = [bool]($doctrineContent -match $pattern)
    Assert-Test -Name "Doctrine indexes $($file.Name)" -Condition $isIndexed
}

# 2. Vault Topics Contract & AST Parsing
Write-Host "`n[Context] Vault Topics Contract & AST Syntax" -ForegroundColor Magenta

foreach ($file in $vaultFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Contract validation
    $hasHeader = [bool]($content -match '# Topic \d+ — .+')
    $hasCat    = [bool]($content -match '\*\*Category:\*\*')
    $hasRiskU  = [bool]($content -match '\*\*Risk for user:\*\*')
    $hasRiskS  = [bool]($content -match '\*\*Security risk \(if not applied\):\*\*')
    $hasReg    = [bool]($content -match '\*\*Affected Registry Keys:\*\*')
    $hasHints  = [bool]($content -match '## Remediation Hints')
    
    $contractOk = $hasHeader -and $hasCat -and $hasRiskU -and $hasRiskS -and $hasReg -and $hasHints
    Assert-Test -Name "$($file.Name) follows markdown contract" -Condition $contractOk
    
    # AST Check Block
    $checkMatch = [regex]::Match($content, '(?ms)## Check\s*```powershell\s*(.*?)\s*```')
    if ($checkMatch.Success) {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($checkMatch.Groups[1].Value, [ref]$tokens, [ref]$errors)
        $hasErr = ($null -ne $errors -and $errors.Count -gt 0)
        $errMsg = if ($hasErr) { ($errors | ForEach-Object { $_.Message }) -join "; " } else { "" }
        Assert-Test -Name "$($file.Name) AST Check block syntax" -Condition (-not $hasErr) -Details $errMsg
    } else {
        Assert-Test -Name "$($file.Name) AST Check block syntax" -Condition $false -Details "Missing ## Check block"
    }

    # AST Apply Block
    $applyMatch = [regex]::Match($content, '(?ms)## Apply\s*```powershell\s*(.*?)\s*```')
    if ($applyMatch.Success) {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($applyMatch.Groups[1].Value, [ref]$tokens, [ref]$errors)
        $hasErr = ($null -ne $errors -and $errors.Count -gt 0)
        $errMsg = if ($hasErr) { ($errors | ForEach-Object { $_.Message }) -join "; " } else { "" }
        Assert-Test -Name "$($file.Name) AST Apply block syntax" -Condition (-not $hasErr) -Details $errMsg
    } else {
        Assert-Test -Name "$($file.Name) AST Apply block syntax" -Condition $false -Details "Missing ## Apply block"
    }

    # AST Rollback Block
    $rollbackMatch = [regex]::Match($content, '(?ms)## Rollback\s*```powershell\s*(.*?)\s*```')
    if ($rollbackMatch.Success) {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($rollbackMatch.Groups[1].Value, [ref]$tokens, [ref]$errors)
        $hasErr = ($null -ne $errors -and $errors.Count -gt 0)
        $errMsg = if ($hasErr) { ($errors | ForEach-Object { $_.Message }) -join "; " } else { "" }
        Assert-Test -Name "$($file.Name) AST Rollback block syntax" -Condition (-not $hasErr) -Details $errMsg
    } else {
        Assert-Test -Name "$($file.Name) AST Rollback block syntax" -Condition $false -Details "Missing ## Rollback block"
    }
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " Passed: $passedTests" -ForegroundColor Green
Write-Host " Failed: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host " Total:  $($passedTests + $failedTests)" -ForegroundColor White

if ($failedTests -gt 0) {
    exit 1
} else {
    exit 0
}

<#
.SYNOPSIS
    Citadel Vault & Doctrine Automated Test Suite
.DESCRIPTION
    Validates Markdown contract compliance, PowerShell AST syntax integrity across
    all Check, Apply, and Rollback code blocks, and Doctrine synchronization.
    Compatible with Pester 3.x, 4.x, and 5.x.
#>

[CmdletBinding()]
param()

$repoRoot = Split-Path -Parent $PSScriptRoot
$vaultPath = Join-Path $repoRoot "directives\vault"
$doctrinePath = Join-Path $repoRoot "directives\hardening-doctrine.md"

Describe "Citadel Vault & Doctrine Integrity" {

    Context "Doctrine Synchronization" {
        It "Should have hardening-doctrine.md present" {
            (Test-Path $doctrinePath) | Should Be $true
        }

        $doctrineContent = Get-Content $doctrinePath -Raw
        $vaultFiles = Get-ChildItem -Path (Join-Path $vaultPath "*.md") | Sort-Object Name

        It "Should contain all vault files in doctrine index" {
            foreach ($file in $vaultFiles) {
                $pattern = "\[$($file.Name)\]\(vault/$($file.Name)\)"
                ($doctrineContent -match $pattern) | Should Be $true
            }
        }
    }

    $vaultFiles = Get-ChildItem -Path (Join-Path $vaultPath "*.md") | Sort-Object Name

    foreach ($file in $vaultFiles) {
        Context "Vault Topic: $($file.Name)" {
            $content = Get-Content $file.FullName -Raw

            It "Should follow the mandatory section contract" {
                ($content -match '# Topic \d+ — .+') | Should Be $true
                ($content -match '\*\*Category:\*\*') | Should Be $true
                ($content -match '\*\*Risk for user:\*\*') | Should Be $true
                ($content -match '\*\*Security risk \(if not applied\):\*\*') | Should Be $true
                ($content -match '\*\*Affected Registry Keys:\*\*') | Should Be $true
                ($content -match '## Check') | Should Be $true
                ($content -match '## Apply') | Should Be $true
                ($content -match '## Rollback') | Should Be $true
                ($content -match '## Remediation Hints') | Should Be $true
            }

            It "Should have valid PowerShell AST syntax in ## Check" {
                if ($content -match '(?ms)## Check\s*```powershell\s*(.*?)\s*```') {
                    $code = $matches[1]
                    $tokens = $null
                    $errors = $null
                    [void][System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$errors)
                    $errorCount = if ($null -eq $errors) { 0 } else { $errors.Count }
                    $errorCount | Should Be 0
                } else {
                    $false | Should Be $true
                }
            }

            It "Should have valid PowerShell AST syntax in ## Apply" {
                if ($content -match '(?ms)## Apply\s*```powershell\s*(.*?)\s*```') {
                    $code = $matches[1]
                    $tokens = $null
                    $errors = $null
                    [void][System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$errors)
                    $errorCount = if ($null -eq $errors) { 0 } else { $errors.Count }
                    $errorCount | Should Be 0
                } else {
                    $false | Should Be $true
                }
            }

            It "Should have valid PowerShell AST syntax in ## Rollback" {
                if ($content -match '(?ms)## Rollback\s*```powershell\s*(.*?)\s*```') {
                    $code = $matches[1]
                    $tokens = $null
                    $errors = $null
                    [void][System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$errors)
                    $errorCount = if ($null -eq $errors) { 0 } else { $errors.Count }
                    $errorCount | Should Be 0
                } else {
                    $false | Should Be $true
                }
            }
        }
    }
}

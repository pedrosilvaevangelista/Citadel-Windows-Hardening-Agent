# Topic 22 — PowerShell 2.0 Engine Deprecation

**Category:** Attack Surface & AMSI Bypass Mitigation
**Risk for user:** NONE — Modern scripts and applications run on PowerShell 5.1 or PowerShell Core 7+. PowerShell 2.0 is obsolete.
**Security risk (if not applied):** HIGH — Attackers execute `powershell.exe -version 2` to downgrade the runtime environment, bypassing AMSI (Antimalware Scan Interface), Script Block Logging, and Transcription auditing. MITRE ATT&CK Vector T1562.001.

**Affected Registry Keys:**
- Optional Windows Feature `MicrosoftWindowsPowerShellV2`

> **Context:** PowerShell 2.0 was introduced in Windows 7. It lacks security telemetry and Antimalware Scan Interface (AMSI) hooks. Disabling the feature closes this downgrade attack vector completely.

---

## Check

```powershell
$feature = try { Get-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -ErrorAction Stop } catch { $null }
if (-not $feature) { return $false }
return ($feature.State -eq "Disabled")
```

## Apply

```powershell
Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart -ErrorAction Stop
```

## Rollback

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2" -NoRestart -ErrorAction SilentlyContinue
```

## Remediation Hints

- If `Disable-WindowsOptionalFeature` fails or times out, use DISM directly: `dism.exe /online /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2 /NoRestart`.
- If the feature is not found on the system (e.g., modern Windows 11 builds that have already stripped it out), the check returns `$true` (SECURE).


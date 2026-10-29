# Topic 21 — Defender PUA Protection (Potentially Unwanted Applications)

**Category:** Malware & Adware Protection
**Risk for user:** LOW — Prevents installation of bundled bloatware, adware, cryptominers, and misleading software bundles.
**Security risk (if not applied):** MEDIUM — Users downloading legitimate utilities bundled with third-party installers often become infected with browser hijackers, system optimizers, or covert background miners. MITRE ATT&CK Vector T1476.

**Affected Registry Keys:**
- `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender` → `PUAProtection`

> **Context:** PUA (Potentially Unwanted Application) protection is an opt-in defense in Windows Defender that identifies software that causes device slowness, serves intrusive advertising, or silently bundles unwanted programs.

---

## Check

```powershell
$pua = (Get-MpPreference -ErrorAction SilentlyContinue).PUAProtection
return ($pua -eq 1)
```

## Apply

```powershell
Set-MpPreference -PUAProtection Enabled -ErrorAction Stop

# Enforce via Policy Registry as well
$defenderPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (!(Test-Path $defenderPolicy)) { New-Item -Path $defenderPolicy -Force | Out-Null }
Set-ItemProperty -Path $defenderPolicy -Name "PUAProtection" -Value 1 -Type DWord -ErrorAction SilentlyContinue
```

## Rollback

```powershell
Set-MpPreference -PUAProtection Disabled -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "PUAProtection" -ErrorAction SilentlyContinue
```

## Remediation Hints

- If `Set-MpPreference` returns an error, verify if Windows Defender is active or managed by third-party antivirus software.
- In managed or enterprise environments, apply directly via `reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v PUAProtection /t REG_DWORD /d 1 /f`.


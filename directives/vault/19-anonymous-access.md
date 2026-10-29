# Topic 19 — Anonymous Access & SAM Enumeration (Null Sessions)

**Category:** Access Control & Information Disclosure
**Risk for user:** NONE — Standard file sharing with credentials continues to function normally.
**Security risk (if not applied):** HIGH — Unauthenticated network attackers can establish null sessions to enumerate local user accounts, groups, and available shares prior to lateral movement. MITRE ATT&CK Vectors T1087.001, T1078.

**Affected Registry Keys:**
- `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` → `RestrictAnonymous`
- `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` → `RestrictAnonymousSAM`
- `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` → `EveryoneIncludesAnonymous`

> **Context:** Null sessions allow anonymous attackers to connect to IPC$ and query the Security Account Manager (SAM) database via RPC. Enforcing anonymous access restrictions blocks unauthorized network discovery.

---

## Check

```powershell
$lsa = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -ErrorAction SilentlyContinue
if (-not $lsa) { return $false }

$rAnon = $lsa.RestrictAnonymous -ge 1
$rSam = $lsa.RestrictAnonymousSAM -ge 1
$everyAnon = $lsa.EveryoneIncludesAnonymous -eq 0

return ($rAnon -and $rSam -and $everyAnon)
```

## Apply

```powershell
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
if (!(Test-Path $lsaPath)) { New-Item -Path $lsaPath -Force | Out-Null }

Set-ItemProperty -Path $lsaPath -Name "RestrictAnonymous" -Value 1 -Type DWord -ErrorAction Stop
Set-ItemProperty -Path $lsaPath -Name "RestrictAnonymousSAM" -Value 1 -Type DWord -ErrorAction Stop
Set-ItemProperty -Path $lsaPath -Name "EveryoneIncludesAnonymous" -Value 0 -Type DWord -ErrorAction Stop
```

## Rollback

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymousSAM" -Value 1 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 0 -Type DWord -ErrorAction SilentlyContinue
```

## Remediation Hints

- If modifying Lsa keys returns Access Denied: use `reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1 /f`.
- Note: Setting `RestrictAnonymous` to `2` can break certain older third-party domain integrations, which is why Level `1` is the recommended enterprise baseline.

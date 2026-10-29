# Topic 18 — NTLM Hardening (NTLMv2 Only)

**Category:** Authentication & Credential Security
**Risk for user:** NONE — Modern Windows environments, domains, and internet services use Kerberos or NTLMv2. Legacy NTLMv1 is completely obsolete.
**Security risk (if not applied):** CRITICAL — NTLMv1 uses broken DES encryption. NetNTLMv1 challenge/responses sniffed on the network can be cracked offline in hours or reversed via rainbow tables to obtain plaintext passwords. MITRE ATT&CK Vector T1557.001.

**Affected Registry Keys:**
- `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` → `LmCompatibilityLevel`

> **Context:** Setting `LmCompatibilityLevel` to `5` instructs Windows to send NTLMv2 responses only and refuse LM & NTLMv1 authentication attempts. This completely eliminates legacy hash downgrade attacks.

---

## Check

```powershell
$val = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -ErrorAction SilentlyContinue).LmCompatibilityLevel
return ($val -ge 5)
```

## Apply

```powershell
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
if (!(Test-Path $lsaPath)) { New-Item -Path $lsaPath -Force | Out-Null }
Set-ItemProperty -Path $lsaPath -Name "LmCompatibilityLevel" -Value 5 -Type DWord -ErrorAction Stop
```

## Rollback

```powershell
# Default Windows value is 3 (Send NTLMv2, negotiate NTLM/LM if requested)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 3 -Type DWord -ErrorAction SilentlyContinue
```

## Remediation Hints

- If `Set-ItemProperty` encounters Access Denied, use `reg.exe`: `reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f`.
- If communicating with ancient legacy NAS devices (SMBv1 era hardware) that fail to authenticate, rollback to level 3 or upgrade the NAS firmware to support NTLMv2.


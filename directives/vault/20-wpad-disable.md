# Topic 20 — Disable WPAD (Web Proxy Auto-Discovery)

**Category:** Network & MITM Protection
**Risk for user:** NONE — Unless the local network relies on a WPAD PAC script for corporate web proxy routing.
**Security risk (if not applied):** HIGH — WPAD broadcast poisoning allows attackers on the local network (using Responder or Inveigh) to force clients to route HTTP/HTTPS traffic through a malicious proxy, harvesting credentials and cleartext web traffic. MITRE ATT&CK Vector T1557.

**Affected Registry Keys:**
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp` → `DisableWpad`
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings` → `EnableAutoProxyResultCache`

> **Context:** When WPAD is enabled, Windows attempts to discover proxy auto-config (PAC) files via DHCP and DNS queries. Attackers easily spoof these responses on local networks to intercept web traffic.

---

## Check

```powershell
$winhttp = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" -ErrorAction SilentlyContinue).DisableWpad
return ($winhttp -eq 1)
```

## Apply

```powershell
$winHttpPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
if (!(Test-Path $winHttpPath)) { New-Item -Path $winHttpPath -Force | Out-Null }
Set-ItemProperty -Path $winHttpPath -Name "DisableWpad" -Value 1 -Type DWord -ErrorAction Stop

# Also disable WPAD execution caching via policy
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
if (!(Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
Set-ItemProperty -Path $policyPath -Name "EnableAutoProxyResultCache" -Value 0 -Type DWord -ErrorAction SilentlyContinue
```

## Rollback

```powershell
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" -Name "DisableWpad" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "EnableAutoProxyResultCache" -ErrorAction SilentlyContinue
```

## Remediation Hints

- If an enterprise environment requires automatic proxy detection, configure explicit proxy settings under `Internet Options` -> `LAN Settings` instead of unauthenticated WPAD broadcasts.


# Topic 17 — Attack Surface Reduction (ASR Rules)

**Category:** Exploit & Behavior Mitigation
**Risk for user:** LOW — Prevents malicious child process spawning and credential dumping while allowing standard applications to run normally.
**Security risk (if not applied):** CRITICAL — Office maldocs, obfuscated scripts, and process injection into LSASS execute unhindered. MITRE ATT&CK Vectors T1059, T1003.001, T1047.

**Affected Registry Keys:**
- `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules` → Rule GUIDs

> **Context:** Attack Surface Reduction (ASR) is a core capability of Microsoft Defender Antivirus. It targets behaviors commonly abused by malware, such as Office apps launching child processes (`powershell.exe`, `cmd.exe`), scripts downloading executable payloads, and unauthorized processes extracting credentials directly from `lsass.exe`.

---

## Check

```powershell
$targetRules = @(
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2", # Block credential stealing from LSASS
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550", # Block executable content from email
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a", # Block Office child processes
    "5beb249e-0dde-4721-b171-49ac04e46a4c", # Block obfuscated scripts
    "e6db77e5-3e12-4247-8177-09377c3827fb", # Block persistence via WMI
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"  # Block untrusted processes from USB
)

$pref = Get-MpPreference -ErrorAction SilentlyContinue
if (-not $pref -or -not $pref.AttackSurfaceReductionRules_Ids) { return $false }

$allSecured = $true
foreach ($rule in $targetRules) {
    $idx = [array]::IndexOf($pref.AttackSurfaceReductionRules_Ids, $rule)
    if ($idx -lt 0 -or $pref.AttackSurfaceReductionRules_Actions[$idx] -ne 1) {
        $allSecured = $false
        break
    }
}
return $allSecured
```

## Apply

```powershell
$targetRules = @(
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2", # Block credential stealing from LSASS
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550", # Block executable content from email
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a", # Block Office child processes
    "5beb249e-0dde-4721-b171-49ac04e46a4c", # Block obfuscated scripts
    "e6db77e5-3e12-4247-8177-09377c3827fb", # Block persistence via WMI
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"  # Block untrusted processes from USB
)

foreach ($rule in $targetRules) {
    Set-MpPreference -AttackSurfaceReductionRules_Ids $rule -AttackSurfaceReductionRules_Actions Enabled -ErrorAction SilentlyContinue
}
```

## Rollback

```powershell
$targetRules = @(
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2",
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550",
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a",
    "5beb249e-0dde-4721-b171-49ac04e46a4c",
    "e6db77e5-3e12-4247-8177-09377c3827fb",
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"
)

foreach ($rule in $targetRules) {
    Set-MpPreference -AttackSurfaceReductionRules_Ids $rule -AttackSurfaceReductionRules_Actions Disabled -ErrorAction SilentlyContinue
}
```

## Remediation Hints

- If `Set-MpPreference` fails due to third-party antivirus installed (which disables Windows Defender): document that Defender ASR requires Windows Defender real-time protection to be active.
- To configure via registry directly if PowerShell cmdlet is blocked: set values in `HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules` with rule GUID as Value Name and `1` (DWORD) as Value Data.

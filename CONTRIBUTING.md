# Contributing to Citadel 🛡️

Thank you for your interest in contributing to **Citadel — Autonomous Hardening Engine for Windows 10/11**!

Citadel is designed as a modular, agentic security framework. Rather than maintaining monolithic, fragile PowerShell scripts, operational capabilities are codified as individual **Vault topics** (`directives/vault/`) and orchestrated through an operational doctrine index (`directives/hardening-doctrine.md`).

Whether you are an **AppSec engineer**, **DevSecOps practitioner**, or **Windows security researcher**, your contributions help make Windows resilient against real-world threat actors.

---

## 🏛️ Architecture Overview

Before contributing, familiarize yourself with Citadel's structure:

```
Citadel - Windows 10-11 Hardening Agent/
├── .github/workflows/ci.yml           # Automated CI testing pipeline
├── AGENTS.md                          # Engine initialization prompt and agent protocol
├── directives/
│   ├── hardening-doctrine.md          # Topic index and doctrine registry
│   └── vault/                         # Security Vault (one Markdown file per topic)
│       ├── 01-critical-services.md
│       ├── ...
│       └── 22-powershell-v2-removal.md
├── tests/
│   └── Vault.Tests.ps1                # Pester automated test suite
├── backups/                           # ONLY .reg registry backups generated at runtime
└── .tmp/                              # Ephemeral runtime scripts (wiped after use)
```

---

## 🚀 Adding a New Hardening Vector

Adding a topic to Citadel involves 4 straightforward steps:

### Step 1 — Create the Vault Topic File
Create a new Markdown file inside `directives/vault/` following the sequential numbering convention:
```text
directives/vault/XX-[topic-slug].md
```
*(e.g., `23-smartscreen-edge.md`)*

### Step 2 — Follow the Vault Contract Template
Every file in `directives/vault/` must strictly adhere to the following structure:

```markdown
# Topic XX — [Descriptive Title]

**Category:** [Attack Surface Reduction | Credential Protection | Network Traffic Control | etc.]
**Risk for user:** [NONE/LOW/MEDIUM/HIGH] — [Clear explanation of user/operational impact]
**Security risk (if not applied):** [LOW/MEDIUM/HIGH/CRITICAL] — [Threat vector, CVE, or MITRE ATT&CK reference]

**Affected Registry Keys:**
- `HKLM\...` → `ValueName`
*(Or "None directly (uses cmdlets / secedit)" if not modifying the registry)*

> **Context:** Clear explanation of why this configuration is vulnerable by default and how attackers exploit it.

---

## Check

```powershell
# Return $true if SECURE, $false if VULNERABLE
# Must be read-only and idempotent.
```

## Apply

```powershell
# PowerShell commands to enforce the hardening setting.
# Use -ErrorAction Stop on critical commands.
```

## Rollback

```powershell
# Reverts the setting to Windows default or safe baseline.
```

## Remediation Hints

- Level 1 / alternative strategy if the Apply command encounters Access Denied or fails.
- Practical troubleshooting advice for edge cases.
```

### Step 3 — Register the Topic in the Doctrine Index
Open [`directives/hardening-doctrine.md`](directives/hardening-doctrine.md) and add a corresponding entry to the **Topic Index** table:

```markdown
| XX | [XX-topic-slug.md](vault/XX-topic-slug.md) | [Category] | [Risk] |
```

### Step 4 — Run Local Tests
Run the automated test suite locally to verify that your new topic complies with the Markdown contract and contains valid PowerShell syntax:

```powershell
.\tests\Vault.Tests.ps1
```

All tests must pass (`Passed: 112, Failed: 0`) before opening a pull request.

---

## 📐 Technical & Coding Standards

To ensure the Citadel agent can execute and reason about your topic safely, observe these standards:

1. **Idempotence is Mandatory:**
   - The `## Check` block must be 100% read-only.
   - Running the `## Apply` block multiple times should yield the same safe state without error or side effects.
2. **Handle Null Values Safely:**
   - Avoid direct method chaining on potentially null registry values (e.g., do not do `(Get-ItemProperty ...).Property.Value` without checking existence or using safe navigation).
3. **Registry Backup Rule:**
   - Only list keys in `**Affected Registry Keys:**` if the topic directly writes to them. Citadel parses this section to create granular `.reg` backups prior to applying changes.
4. **Resilience to Elevation Differences:**
   - Wrap commands that strictly require Administrator rights (such as `Get-WindowsOptionalFeature`) in `try { ... } catch { ... }` in the `## Check` block so that static test runs do not crash.
5. **MITRE ATT&CK Alignment:**
   - Whenever possible, reference specific MITRE ATT&CK techniques (e.g., *T1003.001 - OS Credential Dumping: LSASS Memory*) in the Security Risk line.

---

## 🧪 Pull Request Checklist

Before submitting your PR:

- [ ] New topic file created in `directives/vault/` following the naming standard.
- [ ] Topic includes all required blocks: `# Topic`, `**Category:**`, `**Risk for user:**`, `**Security risk:**`, `**Affected Registry Keys:**`, `## Check`, `## Apply`, `## Rollback`, and `## Remediation Hints`.
- [ ] Topic registered in `directives/hardening-doctrine.md`.
- [ ] `.\tests\Vault.Tests.ps1` passes with zero failures.
- [ ] All code blocks contain valid PowerShell syntax.
- [ ] No temporary files or logs left behind in `.tmp/` or `backups/`.


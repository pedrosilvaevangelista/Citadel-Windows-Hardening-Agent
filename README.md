# Citadel — Autonomous Hardening Engine

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform: Windows 10 | 11](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white)
![Frameworks: CIS & MITRE ATT&CK](https://img.shields.io/badge/Frameworks-CIS%20%7C%20MITRE%20ATT%26CK-red)
![Vectors: 22 Active](https://img.shields.io/badge/Vectors-22%20Active-success)
![Runtime: Antigravity Native](https://img.shields.io/badge/Engine-Google%20Antigravity-purple)

![Citadel Banner](assets/banner.png)

## 🛡️ About

**Citadel** is an **autonomous AI agent** engineered for elite OS security hardening and tactical configuration management on Windows 10/11. It operates beyond the scope of a simple script — it is a full agentic engine with persistent memory, a structured knowledge vault, an autonomous auto-remediation cycle, and surgical runtime validation capabilities.

> [!IMPORTANT]
> Designed **exclusively** to operate natively within the **Antigravity** ecosystem. The `AGENTS.md` file serves as the engine's initialization briefing, loaded at the start of every new session to restore full operational context.

---

## 🔄 Execution Workflow

Citadel runs a deterministic, closed-loop hardening cycle with user-governed approvals:

```mermaid
flowchart TD
    A["Trigger: 'hardening'"] --> B["Phase 1: Pre-Flight Check<br/>(Admin rights, Domain check, Reboot pending)"]
    B --> C["Phase 2: Read-Only Audit<br/>(22 Vault Vectors evaluated in parallel)"]
    C --> D["Phase 3: Interactive Markdown Report<br/>(SECURE vs VULNERABLE status table)"]
    D --> E{"Phase 4: User Approval<br/>(Selected topics or 'all')"}
    E -->|Approved| F["Automatic Registry Backup<br/>(.reg exports saved to backups/)"]
    F --> G["Execution & Validation<br/>(Run Apply script ➔ Run Check script)"]
    G --> H{"Check passed?"}
    H -->|Yes| I["✅ SECURE Status"]
    H -->|No| J["Phase 5: Cascading Remediation<br/>(Level 1 ➔ Level 2 ➔ Self-Healing)"]
    J --> H
    I --> K["Phase 6: Session Closure<br/>(Wipe .tmp/ ➔ Final Summary)"]
    E -->|None| K
```

---

## 🚀 How to Use Citadel

Using Citadel is designed to be interactive and heavily automated. You do not run PowerShell scripts manually — you command the agent, and the agent does the heavy lifting.

### Step-by-Step Execution

1. **Load the Agent:** Open this project directory (`hardening_script-windows10`) inside your **Antigravity** workspace.
2. **Ensure Admin Privileges:** Citadel executes system-level PowerShell commands. **Antigravity must be opened as an Administrator** to ensure the environment has the necessary elevated rights.
3. **Trigger the Engine:** In the Antigravity chat, type the trigger word:
   ```text
   hardening
   ```
4. **Review the Audit:** Citadel will autonomously run a Pre-Flight Check and a Read-Only Audit across 22 security vectors. It will present a Markdown table with the vulnerabilities found.
5. **Command the Fixes:** When Citadel asks *“Which topics do you want to apply?”*, simply reply with the numbers you want to fix (e.g., `1, 3, 14` or `all`).
6. **Watch the Auto-Remediation:** Citadel will automatically backup affected registry keys, apply the fixes, validate them, and trigger cascading remediation strategies if any fix throws an `Access Denied` or service lock error.

### 💾 Automatic Backups
Before making any changes to the system registry during the **Apply** phase, Citadel automatically creates targeted `.reg` backups for the specific registry keys affected by the chosen topics. These backups are safely stored in the `backups/` directory and are timestamped (e.g., `backup-[topic]-[timestamp].reg`). Citadel strictly ensures that only valid `.reg` files are placed in this directory, providing a granular and reliable way to revert individual modifications if ever needed. Topics that do not modify the registry will bypass the backup creation entirely.

### 🛑 Session Interruptions
If your session drops or you need to restart the audit mid-way, you can simply type `hardening` again. Citadel is strictly **idempotent**. The Pre-Flight Audit will naturally detect the fixes that were already applied as `✅ SECURE` and will skip them safely. It will never duplicate configurations or double-backup untouched keys.

### 💻 Command Interface

| Command | Action |
| :--- | :--- |
| `hardening` | Launch the full audit cycle: Pre-Flight → Audit → Question → Apply → Remediate. |
| `hardening upgrade` | Trigger the Autonomous Evolution Cycle (self-upgrade of Doctrine + Vault by adding new attack vectors). |

---

## 🎯 Recommended Model

To ensure maximum technical precision and depth of reasoning during the remediation loop:

> [!WARNING]
> **Recommended:** Claude Sonnet 4.6+, Gemini 3.8 Flash, or equivalent frontier model with extended thinking.
> Using lower-capability models will compromise the detection of complex PowerShell error stacks, autonomous evolution quality, and the execution of the cascading remediation strategies.

---

## 🧠 Architecture

Citadel operates as a **4-layer autonomous engine**:

| Layer | Role | Location |
| :--- | :--- | :--- |
| **Layer 1 — Doctrine Index** | Lightweight persistent memory linking all tactical capabilities. | `directives/hardening-doctrine.md` |
| **Layer 2 — AI Engine** | Real-time PowerShell execution, error reasoning, and auto-remediation. | *(you — the LLM runtime)* |
| **Layer 3 — Ad-Hoc Tooling** | Ephemeral PowerShell scripts for surgical runtime validation. | `.tmp/` *(discarded after use)* |
| **Layer 4 — Security Vault** | 22 tactical knowledge files covering critical attack vectors. | `directives/vault/` |

---

## 🧪 Automated Testing & CI

Citadel features a comprehensive automated test suite built with **Pester** and PowerShell AST analysis:

```powershell
# Run the test suite locally
Invoke-Pester .\tests\Vault.Tests.ps1
```

The test suite validates:
- **Contract Compliance:** Verifies that every topic in `directives/vault/` implements mandatory metadata, risk definitions, and operational blocks (`## Check`, `## Apply`, `## Rollback`, `## Remediation Hints`).
- **Abstract Syntax Tree (AST) Parsing:** Compiles and validates the PowerShell syntax of every script block without requiring execution.
- **Doctrine Parity:** Ensures bidirectional synchronization between `directives/hardening-doctrine.md` and the Vault.

Automated CI runs via **GitHub Actions** on every push and pull request against `main`.

---

## 🤝 Contributing

Contributions from security researchers, AppSec engineers, and DevSecOps practitioners are welcome! Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) for detailed guidelines on how to propose new hardening vectors and pass the automated test suite.

---

## ⚖️ Golden Principle

> You execute. You validate. You remediate. The user only approves — the heavy lifting is yours.
> The vault grows. The `.tmp/` never accumulates garbage. The `backups/` holds only true value.

---

<p align="center">
  <i>Developed by <b><a href="https://github.com/pedrosilvaevangelista">Pinkman</a></b></i>
</p>

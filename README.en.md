# 🧰 UaExpert Simplified Chinese Language Pack

[简体中文](README.md) | **English**

#### A Chinese interface for UaExpert 2.0.2 x64, with straightforward installation and restoration

This package translates everyday menus, server connection dialogs, node panels, and data views into Simplified Chinese. A standalone EXE installs the resources and backs up the previous files.

**[⬇️ Download the installer](https://github.com/donlin-code/UaExpert-zh-CN/releases/latest/download/UaExpert-2.0.2-zh-CN-Setup.exe)** · [Releases](https://github.com/donlin-code/UaExpert-zh-CN/releases) · [Report an issue](https://github.com/donlin-code/UaExpert-zh-CN/issues)

> Supports the **specific official UaExpert 2.0.2 x64 build listed below**. This is an unofficial translation. Install UaExpert separately first. Some interface text and logs remain in English.

---

## 📋 Features

| Feature | What it does |
| --- | --- |
| 🈶 Chinese UI | Menus, toolbars, project tree, address space, attributes, and references |
| 🔌 Common operations | Server connections, data access, events, history, trends, and common settings |
| 💡 Tips | Start-page documentation links and 12 usage tips |
| 📦 Standalone installer | Detects common install locations and accepts the root or bin directory |
| ↩️ Restoration | Backs up resources and restores the state before installation |
| 🔍 Compatibility checks | Verifies original EXE and package SHA-256 checksums before installation |

The catalog contains **4,095 entries**, including accelerator and punctuation variants—not 4,095 distinct screens. Internal plugin names remain unchanged to preserve license matching.

---

## 📦 Installation

1. Install official **UaExpert 2.0.2 x64**.
2. Save your project and close UaExpert.
3. Download `UaExpert-2.0.2-zh-CN-Setup.exe` from [Releases](https://github.com/donlin-code/UaExpert-zh-CN/releases/latest).
4. Run the installer and select the UaExpert directory containing `bin/uaexpert.exe`, or select its `bin` directory directly.
5. Start UaExpert from your usual shortcut.

Administrator rights are required. The installer is **not digitally signed**. GitHub's automatic `Source code (zip)` download contains repository source, not UaExpert itself or the installer.

### Supported build

| Requirement | Value |
| --- | --- |
| OS | 64-bit Windows |
| Application | UaExpert 2.0.2 x64 |
| Original EXE SHA-256 | `be15f711737d0c1df9baf31fa1aa806e2af462ea83e00b1b6d75a2ff1d4cc359` |
| Language-pack version | `v2.0.2-zh.1` |

A different build or modified EXE is rejected even if its displayed version number is the same.

### Verify the download

```powershell
Get-FileHash .\UaExpert-2.0.2-zh-CN-Setup.exe -Algorithm SHA256
```

Compare the result with `SHA256SUMS.txt` in the same release.

---

## ↩️ Restore the previous resources

Save your project and close UaExpert, then either:

- Uninstall **UaExpert 2.0.2 简体中文汉化包** from Windows Apps.
- Run `UaExpert-zh-CN/Restore-English.exe` inside the UaExpert installation directory.

This restores language resources without uninstalling UaExpert. Original backups remain under `UaExpert-zh-CN/backup-*`. Resources edited after installation are preserved separately under `preserved-*`. If a translation was already present before installation, restoration returns to that previous translated state.

---

## 🗂️ Repository layout

```text
UaExpert-zh-CN/
├── README.md                 # Chinese guide
├── README.en.md              # English guide
├── translations.json         # Complete translation dictionary
├── installer/
│   ├── installer.nsi         # NSIS installation UI
│   ├── apply-language.ps1    # Verification, backup, installation, restoration
│   └── payload/              # Start page, tips, and checksum manifest
├── scripts/
│   └── build_catalog.py      # Build and verify Qt QM catalogs
├── release/                  # Checksums and release notes
└── docs/VALIDATION.md         # Validation record and limits
```

### Build locally

Requires Python 3 and NSIS 3.11. The original application is not needed to build the catalogs or compile the installer.

```powershell
python scripts/build_catalog.py
makensis installer/installer.nsi
```

The output is `installer/UaExpert-2.0.2-zh-CN-Setup.exe`. End users should download the EXE directly from Releases. A separate source ZIP is also available there.

---

## 💡 Known limits

- Some hardcoded start-page titles, detailed diagnostic logs, and official help remain in English.
- Server-provided node names, OPC UA identifiers, and status codes are preserved.
- The installer contains language resources only: no application binaries, DLLs, license files, personal projects, or certificates.
- New UaExpert versions may require updated translations and compatibility checks.
- Installation, repeat installation, restoration, and build rejection have been tested. See [Validation](docs/VALIDATION.md). PLC/OPC UA device read/write operations have not been tested.

---

## 🌟 About

A Chinese UI patch for everyday OPC UA debugging. If it helps, a ⭐ is welcome. Report missing translations, wording issues, or installation problems through [Issues](https://github.com/donlin-code/UaExpert-zh-CN/issues), including the application version and reproduction steps. Remove passwords, private keys, and device addresses before posting.

Documentation layout follows [Donlinxg Skills](https://github.com/donlin-code/donlinxg-skills). This project is not affiliated with or endorsed by Unified Automation. The original software remains subject to its vendor license. See [Notices](NOTICE.md).

Made by [@donlin-code](https://github.com/donlin-code)

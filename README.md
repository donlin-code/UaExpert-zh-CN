# 🧰 UaExpert 简体中文汉化包

**简体中文** | [English](README.en.md)

#### 给 UaExpert 2.0.2 x64 加上中文界面，安装和恢复都方便

把日常会用到的菜单、服务器连接窗口、节点面板和数据视图翻成中文，做成一个独立 EXE 安装包。原软件照常使用，汉化前的资源会自动备份。

**[⬇️ 下载汉化安装包](https://github.com/donlin-code/UaExpert-zh-CN/releases/latest/download/UaExpert-2.0.2-zh-CN-Setup.exe)** · [查看版本](https://github.com/donlin-code/UaExpert-zh-CN/releases) · [反馈问题](https://github.com/donlin-code/UaExpert-zh-CN/issues)

> 适配 **官方 UaExpert 2.0.2 x64 的指定构建**。这是非官方汉化包，需要先安装原版 UaExpert，部分界面和日志仍保留英文。

---

## 📋 功能一览

| 内容 | 一句话说明 |
| --- | --- |
| 🈶 中文界面 | 主菜单、工具栏、项目树、地址空间、属性和引用面板 |
| 🔌 常用操作 | 连接服务器、数据访问、事件、历史、趋势及常用设置 |
| 💡 使用技巧 | 起始页文档入口与 12 条使用技巧 |
| 📦 独立安装 | EXE 自动识别常见安装目录，也可手动选择根目录或 bin |
| ↩️ 可恢复 | 自动备份原资源，支持卸载并恢复到安装前状态 |
| 🔍 版本校验 | 检查原始 EXE 与汉化资源的 SHA-256，不匹配就停止安装 |

语言文件包含 **4,095 个条目**，计入快捷键、冒号、省略号等变体，不代表 4,095 个独立界面。插件内部名称保持英文，以兼容软件的授权匹配。

---

## 📦 安装方式

1. 先安装官方 **UaExpert 2.0.2 x64**。
2. 保存项目并关闭 UaExpert。
3. 从 [Releases](https://github.com/donlin-code/UaExpert-zh-CN/releases/latest) 下载 `UaExpert-2.0.2-zh-CN-Setup.exe`。
4. 运行安装包，选择 UaExpert 安装目录。目录里应有 `bin/uaexpert.exe`，也可以直接选 `bin`。
5. 安装完成后，从原来的快捷方式启动 UaExpert。

安装程序需要管理员权限，当前产物**未做数字签名**。下载页自动生成的 `Source code (zip)` 是仓库源码，不是软件本体或安装程序。

### 适配版本

| 项目 | 要求 |
| --- | --- |
| 系统 | 64 位 Windows |
| 软件 | UaExpert 2.0.2 x64 |
| 原始 EXE SHA-256 | `be15f711737d0c1df9baf31fa1aa806e2af462ea83e00b1b6d75a2ff1d4cc359` |
| 汉化包版本 | `v2.0.2-zh.1` |

即便显示同样的版本号，若构建不同或 EXE 被修改，安装程序也会拒绝安装。

### 验证下载

```powershell
Get-FileHash .\UaExpert-2.0.2-zh-CN-Setup.exe -Algorithm SHA256
```

将结果与同一 Release 中的 `SHA256SUMS.txt` 对照。

---

## ↩️ 恢复安装前状态

保存项目并关闭 UaExpert，然后任选一种方式：

- 在 Windows 应用列表中卸载 **UaExpert 2.0.2 简体中文汉化包**。
- 运行软件安装目录中的 `UaExpert-zh-CN/Restore-English.exe`。

它只恢复语言资源，不卸载 UaExpert。最初备份保留在 `UaExpert-zh-CN/backup-*`；安装后手动修改过的资源会另存到 `preserved-*`。如果安装前就已经汉化，卸载会恢复到此前的汉化状态。

---

## 🗂️ 仓库结构

```text
UaExpert-zh-CN/
├── README.md                 # 中文说明
├── README.en.md              # English guide
├── translations.json         # 完整的翻译字典
├── installer/
│   ├── installer.nsi         # NSIS 安装界面
│   ├── apply-language.ps1    # 校验、备份、安装与恢复
│   └── payload/              # 起始页、技巧和校验清单
├── scripts/
│   └── build_catalog.py      # 生成并验证 Qt QM 文件
├── release/                  # 校验值与版本说明
└── docs/VALIDATION.md         # 验证记录与边界
```

### 本地构建

需要 Python 3 和 NSIS 3.11。仓库不需要 UaExpert 主程序即可生成语言文件和编译安装器。

```powershell
python scripts/build_catalog.py
makensis installer/installer.nsi
```

编译结果在 `installer/UaExpert-2.0.2-zh-CN-Setup.exe`。普通用户直接下载 Release 中的 EXE 即可；Release 还提供单独的源码 ZIP。

---

## 💡 已知边界

- 起始页部分硬编码标题、详细诊断日志和官方帮助文档仍为英文。
- 服务器返回的节点名称、OPC UA 标识符和状态码保持原文。
- 安装包只带语言资源，不含软件本体、DLL、授权文件、个人项目或证书。
- 更新 UaExpert 后可能需要重新适配，不建议把这个包用于其他版本。
- 已验证安装、重复安装、恢复及版本拦截，详见 [验证记录](docs/VALIDATION.md)。未做 PLC/OPC UA 设备读写测试。

---

## 🌟 关于

一个面向日常 OPC UA 调试的中文界面补丁。如果对你有帮助，欢迎给个 ⭐。遇到漏翻、翻译不准确或安装问题，可以在 [Issues](https://github.com/donlin-code/UaExpert-zh-CN/issues) 留下软件版本、相关界面文字和复现步骤，请隐去密码、私钥及设备地址等敏感信息。

说明排版参考 [Donlinxg Skills](https://github.com/donlin-code/donlinxg-skills)。本项目与 Unified Automation 无隶属或背书关系，原软件仍适用其厂商许可，详见 [声明](NOTICE.md)。

Made by [@donlin-code](https://github.com/donlin-code)

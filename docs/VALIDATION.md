# 验证记录 / Validation

2026-10-25：从保留的 NSIS 3.11 安装源码重新编译正式 EXE，SHA-256 与 2026-09-18 的产物一致：

`892e0cad08658536448ea821bbd3029e7de52d3f02f2916afd7159c23574477a`

重新运行使用相同安装逻辑、用户权限测试构建的隔离目录测试：

| 检查 / Check | 结果 / Result |
| --- | --- |
| 中文和空格路径 / Unicode and spaced paths | PASS |
| 安装资源逐文件校验 / Installed file checksums | PASS |
| 原始 EXE 保持不变 / Original executable unchanged | PASS |
| 重复安装保留最初备份 / Repeat install keeps original backup | PASS |
| 接受 bin 目录 / Accepts bin directory | PASS |
| 卸载恢复每个原文件 / Restores every original file | PASS |
| 保留安装后手动修改 / Preserves later user edits | PASS |
| 拒绝错误版本且不修改文件 / Rejects unsupported builds without changes | PASS |

此前已使用 UaExpert 自带 Qt5Core.dll 验证 4,095 条翻译、插件名称不被翻译、en_US 环境的默认语言文件回退；实际界面已检查主菜单、面板和添加服务器窗口。

The production installer was rebuilt with NSIS 3.11 on 2026-10-25 and matches the original artifact checksum. Isolated tests were rerun using a user-level build with the same installation logic. Earlier verification used the bundled Qt5Core.dll to validate all 4,095 entries, unchanged plugin identifiers, and the en_US fallback. Main UI panels and the Add Server dialog were also inspected.

未进行 PLC/OPC UA 设备读写测试，也未验证所有 Windows 版本及每个对话框。正式 EXE 需要管理员权限；隔离自动测试使用用户权限构建。

PLC/OPC UA device read/write operations, every Windows version, and every dialog have not been tested. The production EXE requests elevation; automated isolated tests use a user-level build.

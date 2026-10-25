Unicode True
!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!define MUI_ABORTWARNING
!define PRODUCT "UaExpert 2.0.2 简体中文汉化包"
!ifdef TEST_BUILD
RequestExecutionLevel user
!define UNINSTALL_ROOT HKCU
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\UaExpertZhCN-InstallerTest"
OutFile "UaExpert-zh-CN-test.exe"
!else
RequestExecutionLevel admin
!define UNINSTALL_ROOT HKLM
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\UaExpertZhCN"
OutFile "UaExpert-2.0.2-zh-CN-Setup.exe"
!endif
Name "${PRODUCT}"
InstallDir "$PROGRAMFILES64\UnifiedAutomation\UaExpert"
BrandingText "UaExpert 非官方中文语言包"
SetCompressor /SOLID lzma
ShowInstDetails show
ShowUninstDetails show
VIProductVersion "2.0.2.1"
VIAddVersionKey /LANG=2052 "ProductName" "${PRODUCT}"
VIAddVersionKey /LANG=2052 "FileDescription" "UaExpert 简体中文语言资源安装程序"
VIAddVersionKey /LANG=2052 "FileVersion" "2.0.2.1"
VIAddVersionKey /LANG=2052 "LegalCopyright" "非官方语言包；UaExpert 商标归原厂所有"
!define MUI_WELCOMEPAGE_TITLE "安装 UaExpert 简体中文语言包"
!define MUI_WELCOMEPAGE_TEXT "适用于原版 UaExpert 2.0.2 x64。请先保存项目并关闭 UaExpert。$\r$\n$\r$\n安装程序将备份并替换语言资源，不修改软件 EXE、DLL、项目或证书。$\r$\n$\r$\n这是非官方汉化，部分硬编码标题、帮助文档和诊断日志仍为英文。"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "payload\说明.txt"
!define MUI_DIRECTORYPAGE_TEXT_TOP "请选择已安装的 UaExpert 根目录（其中包含 bin 文件夹），也可选择 bin 目录。"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TEXT "汉化安装完成。直接从原快捷方式启动 UaExpert 即可。$\r$\n$\r$\n如需恢复安装前的语言资源，可在 Windows 应用列表卸载此汉化包，或运行安装目录 UaExpert-zh-CN 中的 Restore-English.exe。"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_ICONSTOP "仅支持 64 位 Windows 和 UaExpert 2.0.2 x64。" /SD IDOK
        SetErrorLevel 10
        Quit
    ${EndIf}
    SetRegView 64
    StrCpy $LANGUAGE 2052
    ; An explicit /D destination always wins over automatic discovery.
    StrCmp $INSTDIR "$PROGRAMFILES64\UnifiedAutomation\UaExpert" 0 done
    StrCpy $0 0
    loop:
        EnumRegKey $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" $0
        StrCmp $1 "" done
        IntOp $0 $0 + 1
        ReadRegStr $2 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$1" "DisplayName"
        StrCmp $2 "UaExpert" 0 loop
        ReadRegStr $2 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$1" "InstallLocation"
        IfFileExists "$2\bin\uaexpert.exe" 0 loop
        StrCpy $INSTDIR $2
    done:
FunctionEnd

Function .onVerifyInstDir
    IfFileExists "$INSTDIR\bin\uaexpert.exe" valid
    IfFileExists "$INSTDIR\uaexpert.exe" valid
    Abort
    valid:
FunctionEnd

Section "中文语言资源"
    IfFileExists "$INSTDIR\uaexpert.exe" 0 rootready
    ${GetParent} "$INSTDIR" $INSTDIR
    rootready:
    InitPluginsDir
    SetOutPath "$PLUGINSDIR\uaexpert-zh"
    File "apply-language.ps1"
    SetOutPath "$PLUGINSDIR\uaexpert-zh\payload"
    File /r "payload\*"
    DetailPrint "检查版本、备份原文件并安装语言资源…"
    ${DisableX64FSRedirection}
    nsExec::ExecToStack '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$PLUGINSDIR\uaexpert-zh\apply-language.ps1" -Mode Install -TargetDir "$INSTDIR" -PayloadDir "$PLUGINSDIR\uaexpert-zh\payload"'
    Pop $0
    Pop $1
    DetailPrint $1
    FileOpen $2 "$TEMP\UaExpert-zh-CN-install.log" w
    FileWrite $2 $1
    FileClose $2
    ${EnableX64FSRedirection}
    StrCmp $0 "0" installed
        MessageBox MB_ICONSTOP "汉化未安装。请检查上方日志：需要关闭 UaExpert、选择正确目录，且必须为原版 2.0.2 x64。错误代码：$0" /SD IDOK
        SetErrorLevel 10
        Abort
    installed:
    SetOutPath "$INSTDIR\UaExpert-zh-CN"
    WriteUninstaller "$INSTDIR\UaExpert-zh-CN\Restore-English.exe"
    WriteRegStr ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "DisplayName" "${PRODUCT}（仅语言资源）"
    WriteRegStr ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "DisplayVersion" "2.0.2.1"
    WriteRegStr ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "UninstallString" '$\"$INSTDIR\UaExpert-zh-CN\Restore-English.exe$\"'
    WriteRegDWORD ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "NoModify" 1
    WriteRegDWORD ${UNINSTALL_ROOT} "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Function un.onInit
    StrCpy $INSTDIR "$EXEDIR"
FunctionEnd

Section "Uninstall"
    SetRegView 64
    ; The uninstaller lives in the language pack subfolder, one below UaExpert.
    ${GetParent} "$INSTDIR" $0
    ${DisableX64FSRedirection}
    nsExec::ExecToStack '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$INSTDIR\apply-language.ps1" -Mode Uninstall -TargetDir "$0"'
    Pop $1
    Pop $2
    DetailPrint $2
    FileOpen $3 "$TEMP\UaExpert-zh-CN-uninstall.log" w
    FileWrite $3 $2
    FileClose $3
    ${EnableX64FSRedirection}
    StrCmp $1 "0" restored
        MessageBox MB_ICONSTOP "恢复未完成，请关闭 UaExpert 后重试，并查看上方日志。原备份已保留。" /SD IDOK
        SetErrorLevel 10
        Abort
    restored:
    DeleteRegKey ${UNINSTALL_ROOT} "${UNINSTALL_KEY}"
    Delete "$INSTDIR\Restore-English.exe"
    DetailPrint "已恢复安装前资源。备份保留在 UaExpert-zh-CN 文件夹。"
SectionEnd

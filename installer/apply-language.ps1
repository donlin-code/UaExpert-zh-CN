param(
    [ValidateSet('Install','Uninstall','Check')][string]$Mode = 'Install',
    [Parameter(Mandatory=$true)][string]$TargetDir,
    [string]$PayloadDir = ''
)
$ErrorActionPreference = 'Stop'
if (-not $PayloadDir) { $PayloadDir = Join-Path $PSScriptRoot 'payload' }
$stateRoot = $null
function Get-PackageHash($LiteralPath, $Algorithm) {
    $stream = [IO.File]::OpenRead($LiteralPath)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return [PSCustomObject]@{Hash = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')} }
    finally { $stream.Dispose(); $sha.Dispose() }
}
function Save-Json($Data, $Path) {
    $Data | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}
function Resolve-SafeChild($Root, $Relative) {
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    $child = [IO.Path]::GetFullPath((Join-Path $base $Relative))
    if (-not $child.StartsWith($base + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Invalid path in package manifest.'
    }
    return $child
}
function Restore-Files($Records, $Root, $Backup) {
    foreach ($record in $Records) {
        $destination = Resolve-SafeChild $Root $record.path
        if ($record.existed) {
            $saved = Resolve-SafeChild $Backup $record.path
            if ((Get-PackageHash -LiteralPath $saved -Algorithm SHA256).Hash -ne $record.originalHash) {
                throw ('Backup verification failed: ' + $record.path)
            }
            Copy-Item -LiteralPath $saved -Destination $destination -Force
        } elseif (Test-Path -LiteralPath $destination) {
            Remove-Item -LiteralPath $destination -Force
        }
    }
}
try {
    $appRoot = (Resolve-Path -LiteralPath $TargetDir).Path.TrimEnd('\')
    if (Test-Path -LiteralPath (Join-Path $appRoot 'uaexpert.exe')) {
        $appRoot = Split-Path -Parent $appRoot
    }
    $exe = Join-Path $appRoot 'bin\uaexpert.exe'
    if (-not (Test-Path -LiteralPath $exe)) { throw 'Select the UaExpert installation folder (or its bin folder).' }
    $stateRoot = Join-Path $appRoot 'UaExpert-zh-CN'
    $statePath = Join-Path $stateRoot 'state.json'
    if ($Mode -ne 'Uninstall') {
        $package = Get-Content -LiteralPath (Join-Path $PayloadDir 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        if ((Get-PackageHash -LiteralPath $exe -Algorithm SHA256).Hash -ne $package.exeSha256) {
            throw 'This language pack supports only the original UaExpert 2.0.2 x64 build. No files were changed.'
        }
        foreach ($entry in $package.files) {
            $source = Resolve-SafeChild $PayloadDir $entry.path
            if ((Get-PackageHash -LiteralPath $source -Algorithm SHA256).Hash -ne $entry.sha256) {
                throw ('Package verification failed: ' + $entry.path)
            }
        }
    }
    if ($Mode -eq 'Check') { Write-Output 'PASS: supported UaExpert build and intact language package'; exit 0 }
    foreach ($process in (Get-Process uaexpert -ErrorAction SilentlyContinue)) {
        if (-not $process.Path -or [String]::Equals($process.Path, $exe, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Save your project and close UaExpert in this folder before installing or restoring the language pack.'
        }
    }
    if ($Mode -eq 'Uninstall') {
        if (-not (Test-Path -LiteralPath $statePath)) { throw 'No installed language pack state was found.' }
        $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not [String]::Equals($state.target,$appRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Installation state belongs to a different folder.' }
        $backupRoot = Resolve-SafeChild $stateRoot $state.backupDirectory
        # Verify all backups before restoring any file.
        foreach ($entry in $state.files) {
            if ($entry.existed -and (Get-PackageHash -LiteralPath (Resolve-SafeChild $backupRoot $entry.path) -Algorithm SHA256).Hash -ne $entry.originalHash) {
                throw ('Backup verification failed: ' + $entry.path)
            }
        }
        $preservedRoot = Join-Path $stateRoot ('preserved-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
        foreach ($entry in $state.files) {
            $current = Resolve-SafeChild $appRoot $entry.path
            if ((Test-Path -LiteralPath $current) -and (Get-PackageHash -LiteralPath $current -Algorithm SHA256).Hash -ne $entry.installedHash) {
                $saved = Resolve-SafeChild $preservedRoot $entry.path
                New-Item -ItemType Directory -Path (Split-Path -Parent $saved) -Force | Out-Null
                Copy-Item -LiteralPath $current -Destination $saved
            }
        }
        Restore-Files $state.files $appRoot $backupRoot
        Move-Item -LiteralPath $statePath -Destination (Join-Path $backupRoot 'completed-state.json') -Force
        Write-Output 'Original language resources restored. Recovery backups have been kept.'
        exit 0
    }
    if (Test-Path -LiteralPath $statePath) {
        $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not [String]::Equals($state.target,$appRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Installation state belongs to a different folder.' }
        $backupRoot = Resolve-SafeChild $stateRoot $state.backupDirectory
        if (@($state.files).Count -ne @($package.files).Count) { throw 'Uninstall the older language pack before changing package contents.' }
        foreach ($entry in $state.files) {
            if (-not ($package.files.path -contains $entry.path)) { throw 'Package file list changed; restore the previous language pack first.' }
            if ($entry.existed -and (Get-PackageHash -LiteralPath (Resolve-SafeChild $backupRoot $entry.path) -Algorithm SHA256).Hash -ne $entry.originalHash) { throw 'Original backup is missing or damaged.' }
            $current = Resolve-SafeChild $appRoot $entry.path
            if ((Test-Path -LiteralPath $current) -and (Get-PackageHash -LiteralPath $current -Algorithm SHA256).Hash -ne $entry.installedHash) { throw 'A translated file was changed after installation. Restore the old language pack before reinstalling.' }
        }
    } else {
        New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
        $backupName = 'backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
        $backupRoot = Join-Path $stateRoot $backupName
        $records = @()
        foreach ($entry in $package.files) {
            $destination = Resolve-SafeChild $appRoot $entry.path
            $exists = Test-Path -LiteralPath $destination
            $originalHash = $null
            if ($exists) {
                $saved = Resolve-SafeChild $backupRoot $entry.path
                New-Item -ItemType Directory -Path (Split-Path -Parent $saved) -Force | Out-Null
                Copy-Item -LiteralPath $destination -Destination $saved
                $originalHash = (Get-PackageHash -LiteralPath $saved -Algorithm SHA256).Hash
            }
            $records += [PSCustomObject]@{path=$entry.path; existed=$exists; originalHash=$originalHash; installedHash=$entry.sha256}
        }
        $state = [PSCustomObject]@{version=1; target=$appRoot; backupDirectory=$backupName; files=$records}
        Save-Json $state $statePath
    }
    try {
        foreach ($entry in $package.files) {
            $destination = Resolve-SafeChild $appRoot $entry.path
            New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
            Copy-Item -LiteralPath (Resolve-SafeChild $PayloadDir $entry.path) -Destination $destination -Force
            if ((Get-PackageHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $entry.sha256) { throw 'Written file verification failed.' }
            ($state.files | Where-Object { $_.path -eq $entry.path }).installedHash = $entry.sha256
        }
        Save-Json $state $statePath
        Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $stateRoot 'apply-language.ps1') -Force
        Copy-Item -LiteralPath (Join-Path $PayloadDir '说明.txt') -Destination (Join-Path $stateRoot '说明.txt') -Force
    } catch {
        Restore-Files $state.files $appRoot $backupRoot
        if (Test-Path -LiteralPath $statePath) { Move-Item -LiteralPath $statePath -Destination (Join-Path $backupRoot 'rolled-back-state.json') -Force }
        throw
    }
    Write-Output 'Chinese language pack installed and verified. Start UaExpert normally.'
    exit 0
} catch {
    $failure = $_.Exception.Message
    [Console]::Error.WriteLine($failure)
    if ($stateRoot -and (Test-Path -LiteralPath $stateRoot)) {
        $failure | Add-Content -LiteralPath (Join-Path $stateRoot 'last-error.txt') -Encoding UTF8
    }
    exit 10
}

param(
    [string]$Message = "Update translations $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    [switch]$NoPush
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$allowedExact = @(
    '.gitignore',
    'README.md',
    'manifest.txt',
    'scripts/Update-Manifest.ps1',
    'scripts/Publish-Translations.ps1'
)

function Assert-AllowedPath {
    param([Parameter(Mandatory)][string]$Path)

    $normalized = $Path.Replace('\', '/')
    if ($normalized -in $allowedExact) {
        return
    }
    if ($normalized -match '^translations/zh-TW/(Text|Texture)/[^/]+\.(txt|png)$') {
        return
    }
    throw "Refusing to publish a path outside the translation allowlist: $normalized"
}

Set-Location -LiteralPath $repoRoot
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot '.git') -PathType Container)) {
    throw "Not a Git repository: $repoRoot"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed or is not available in PATH.'
}

& (Join-Path $PSScriptRoot 'Update-Manifest.ps1') -RepoRoot $repoRoot

$tracked = @(& git ls-files)
if ($LASTEXITCODE -ne 0) { throw 'Unable to read tracked Git files.' }
foreach ($path in $tracked) { Assert-AllowedPath -Path $path }

& git add -- '.gitignore' 'README.md' 'manifest.txt' 'scripts/Update-Manifest.ps1' 'scripts/Publish-Translations.ps1' 'translations'
if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }

$staged = @(& git diff --cached --name-only --diff-filter=ACMR)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect staged files.' }
foreach ($path in $staged) { Assert-AllowedPath -Path $path }

if (-not $staged) {
    Write-Host 'No translation changes to publish.'
    exit 0
}

& git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Git detected invalid whitespace or conflict markers.' }

Write-Host 'Files approved for publication:'
$staged | ForEach-Object { Write-Host "  $_" }
& git commit -m $Message
if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }

if ($NoPush) {
    Write-Host 'Commit created. Push skipped because -NoPush was specified.'
    exit 0
}

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push failed.' }
Write-Host 'Translation update published successfully.'


param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$translationsRoot = Join-Path $RepoRoot 'translations'
$manifestPath = Join-Path $RepoRoot 'manifest.txt'
$allowedExtensions = @('.txt', '.png')

if (-not (Test-Path -LiteralPath $translationsRoot -PathType Container)) {
    throw "translations folder not found: $translationsRoot"
}

$resolvedRoot = (Resolve-Path -LiteralPath $translationsRoot).Path.TrimEnd('\') + '\'
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# relative/path|sha256|size')

Get-ChildItem -LiteralPath $translationsRoot -Recurse -File |
    Sort-Object FullName |
    ForEach-Object {
        if (($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Linked files are not allowed in translations: $($_.FullName)"
        }

        $extension = $_.Extension.ToLowerInvariant()
        if ($extension -notin $allowedExtensions) {
            throw "Unsupported file in translations: $($_.FullName)"
        }

        $fullPath = (Resolve-Path -LiteralPath $_.FullName).Path
        $relative = $fullPath.Substring($resolvedRoot.Length).Replace('\', '/')
        if ($relative -notmatch '^zh-TW/(Text|Texture)/[^/]+$') {
            throw "Translation path is outside the allowlist: $relative"
        }

        $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        $lines.Add("$relative|$hash|$($_.Length)")
    }

if ($lines.Count -le 1) {
    throw 'Refusing to publish an empty translation manifest.'
}

$utf8NoBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllLines($manifestPath, $lines, $utf8NoBom)
Write-Host "Updated manifest with $($lines.Count - 1) entries: $manifestPath"


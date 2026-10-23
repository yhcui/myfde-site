# myfde deploy: build -> commit source -> push main -> publish public/ to deploy branch
# Pushes to all remotes (origin=GitHub, gitee=Gitee mirror if configured)
# Usage: .\deploy.ps1 [-Message "note"]
param([string]$Message = "")

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$remoteNames = @()
foreach ($r in @("origin", "gitee")) {
  if ((git remote) -contains $r) { $remoteNames += $r }
}
if ($remoteNames.Count -eq 0) { throw "No git remote configured. Run: git remote add origin <url>" }

Write-Host "[1/4] Hugo build..." -ForegroundColor Cyan
hugo --minify --cleanDestinationDir
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }

Write-Host "[2/4] Commit source..." -ForegroundColor Cyan
git add -A
$staged = git diff --cached --name-only
if ($staged) {
  if (-not $Message) { $Message = "content update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
  git commit -m $Message
} else {
  Write-Host "  No source changes, skip commit"
}

Write-Host "[3/4] Push main..." -ForegroundColor Cyan
foreach ($r in $remoteNames) { Write-Host "  -> $r"; git push $r main }

Write-Host "[4/4] Update deploy branch..." -ForegroundColor Cyan
$tmp = Join-Path $env:TEMP "myfde-deploy-tmp"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
git clone --no-hardlinks --quiet $PSScriptRoot $tmp
Set-Location $tmp
git config core.autocrlf false
git remote set-url origin (git -C $PSScriptRoot remote get-url origin)
if ((git -C $PSScriptRoot remote) -contains "gitee") { git remote add gitee (git -C $PSScriptRoot remote get-url gitee) }
# chain to previous remote deploy: linear history so server can git pull
git fetch --quiet origin deploy 2>$null
if ($LASTEXITCODE -ne 0) { git fetch --quiet origin deploy 2>$null }
if ($LASTEXITCODE -ne 0) { Write-Host "  WARN: cannot fetch previous deploy, history restarts (server: fetch+reset)" -ForegroundColor Yellow }
if (git rev-parse --verify --quiet origin/deploy) {
  git checkout --quiet -f -B deploy origin/deploy
} else {
  git checkout --quiet --orphan deploy
}
git rm -rf --cached --quiet . 2>$null
Get-ChildItem -Exclude ".git" | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $PSScriptRoot "public\*") -Destination . -Recurse -Force
git add -A
git commit --quiet -m "deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
foreach ($r in $remoteNames) { Write-Host "  -> $r"; git push --force $r deploy }
Set-Location $PSScriptRoot
Remove-Item -Recurse -Force $tmp

Write-Host "Done. On server: cd /var/www/myfde && git fetch origin deploy && git reset --hard origin/deploy" -ForegroundColor Green

# myfde 部署脚本：构建 -> 提交源码 -> 推 main -> 构建产物推 deploy 分支
# 同时推送到所有远程仓库（origin=GitHub，gitee=Gitee 镜像，gitee 存在才推）
# 用法： .\deploy.ps1 [-Message "说明"]
param([string]$Message = "")

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# 收集远程仓库
$remoteNames = @()
foreach ($r in @("origin", "gitee")) {
  if ((git remote) -contains $r) { $remoteNames += $r }
}
if ($remoteNames.Count -eq 0) { throw "没有配置远程仓库，先运行: git remote add origin <url>" }

# 1. 构建
Write-Host "[1/4] Hugo 构建..." -ForegroundColor Cyan
hugo --minify --cleanDestinationDir
if ($LASTEXITCODE -ne 0) { throw "Hugo 构建失败" }

# 2. 提交源码变更
Write-Host "[2/4] 提交源码..." -ForegroundColor Cyan
git add -A
$staged = git diff --cached --name-only
if ($staged) {
  if (-not $Message) { $Message = "content update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
  git commit -m $Message
} else {
  Write-Host "  源码无变更，跳过提交"
}

# 3. 推送 main（源码）到所有远程
Write-Host "[3/4] 推送 main 分支..." -ForegroundColor Cyan
foreach ($r in $remoteNames) { Write-Host "  -> $r"; git push $r main }

# 4. 构建产物 -> deploy 分支（孤儿分支，每次重建），推到所有远程
Write-Host "[4/4] 更新 deploy 分支..." -ForegroundColor Cyan
$tmp = Join-Path $env:TEMP "myfde-deploy-tmp"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
git clone --no-hardlinks --quiet $PSScriptRoot $tmp
Set-Location $tmp
git config core.autocrlf false
git remote set-url origin (git -C $PSScriptRoot remote get-url origin)
if ((git -C $PSScriptRoot remote) -contains "gitee") { git remote add gitee (git -C $PSScriptRoot remote get-url gitee) }
# 以上一版远程 deploy 为父提交，保持线性历史（服务器才能正常 git pull）
git fetch --quiet origin deploy 2>$null
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

Write-Host "完成。服务器上执行: cd /var/www/myfde && git pull" -ForegroundColor Green

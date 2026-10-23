# myfde 部署脚本：构建 -> 提交源码 -> 推 main -> 构建产物推 deploy 分支
# 用法： .\deploy.ps1 [-Message "说明"] [-Remote origin]
param(
  [string]$Message = "",
  [string]$Remote = "origin"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# 1. 构建（--minify 压缩输出）
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

# 3. 推送 main（源码）
Write-Host "[3/4] 推送 main 分支..." -ForegroundColor Cyan
git push $Remote main

# 4. 构建产物 -> deploy 分支（孤儿分支，每次重建，服务器只拉这个分支）
Write-Host "[4/4] 更新 deploy 分支..." -ForegroundColor Cyan
$originUrl = git remote get-url origin
if (-not $originUrl) { throw "没有 origin 远程仓库，先运行: git remote add origin <url>" }
$tmp = Join-Path $env:TEMP "myfde-deploy-tmp"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
git clone --no-hardlinks --quiet $PSScriptRoot $tmp
Set-Location $tmp
git remote set-url origin $originUrl
git config core.autocrlf false
git checkout --quiet --orphan deploy
git rm -rf --cached --quiet .
Get-ChildItem -Exclude ".git" | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $PSScriptRoot "public\*") -Destination . -Recurse -Force
git add -A
git commit --quiet -m "deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push --force origin deploy
Set-Location $PSScriptRoot
Remove-Item -Recurse -Force $tmp

Write-Host "完成。服务器上执行: cd /var/www/myfde && git pull" -ForegroundColor Green

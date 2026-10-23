#!/usr/bin/env bash
# myfde 部署脚本（macOS / Linux）：构建 -> 提交源码 -> 推 main -> 构建产物推 deploy 分支
# 用法： ./deploy.sh "提交说明"
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
cd "$SRC"
MSG="${1:-}"

echo "[1/4] Hugo 构建..."
hugo --minify --cleanDestinationDir

echo "[2/4] 提交源码..."
git add -A
if ! git diff --cached --quiet; then
  if [ -z "$MSG" ]; then MSG="content update $(date '+%Y-%m-%d %H:%M')"; fi
  git commit -m "$MSG"
else
  echo "  源码无变更，跳过提交"
fi

echo "[3/4] 推送 main 分支..."
git push origin main

echo "[4/4] 更新 deploy 分支..."
ORIGIN_URL=$(git remote get-url origin)
[ -n "$ORIGIN_URL" ] || { echo "没有 origin，先 git remote add origin <url>"; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone --no-hardlinks --quiet "$SRC" "$TMP"
cd "$TMP"
git remote set-url origin "$ORIGIN_URL"
git checkout --quiet --orphan deploy
git rm -rf --cached --quiet .
find . -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +
cp -r "$SRC"/public/* .
git add -A
git commit --quiet -m "deploy $(date '+%Y-%m-%d %H:%M')"
git push --force origin deploy

echo "完成。服务器上执行: cd /var/www/myfde && git pull"

#!/usr/bin/env bash
# myfde 部署脚本（macOS / Linux）：构建 -> 提交源码 -> 推 main -> 构建产物推 deploy 分支
# 同时推送到所有远程仓库（origin=GitHub，gitee=Gitee 镜像，gitee 存在才推）
# 用法： ./deploy.sh "提交说明"
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
cd "$SRC"
MSG="${1:-}"

# 收集远程仓库
REMOTE_NAMES=""
for r in origin gitee; do
  if git remote | grep -qx "$r"; then REMOTE_NAMES="$REMOTE_NAMES $r"; fi
done
[ -n "$REMOTE_NAMES" ] || { echo "没有远程仓库，先 git remote add origin <url>"; exit 1; }

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
for r in $REMOTE_NAMES; do echo "  -> $r"; git push "$r" main; done

echo "[4/4] 更新 deploy 分支..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone --no-hardlinks --quiet "$SRC" "$TMP"
cd "$TMP"
git config core.autocrlf false
git remote set-url origin "$(git -C "$SRC" remote get-url origin)"
if git -C "$SRC" remote | grep -qx gitee; then git remote add gitee "$(git -C "$SRC" remote get-url gitee)"; fi
git checkout --quiet --orphan deploy
git rm -rf --cached --quiet .
find . -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +
cp -r "$SRC"/public/* .
git add -A
git commit --quiet -m "deploy $(date '+%Y-%m-%d %H:%M')"
for r in $REMOTE_NAMES; do echo "  -> $r"; git push --force "$r" deploy; done

echo "完成。服务器上执行: cd /var/www/myfde && git pull"

# myfde.top 站点仓库

myfde.top 的源码与部署脚本。Hugo 静态站点（野战手册风格），构建产物推 `deploy` 分支，服务器只拉 `deploy`。

**核心思想：仓库就是一切。** 文章、模板、样式、脚本全在 GitHub（https://github.com/yhcui/myfde-site）里，任何电脑装好 git + hugo 再 clone 下来，就是完整可用的写作环境。

```
content/            文章（markdown + front matter）
layouts/            模板（野战手册主题，无第三方依赖）
assets/css/         样式
static/             静态文件（favicon、llms.txt）
deploy/             服务器用的 nginx 配置片段
deploy.ps1          一键发布（Windows）
deploy.sh           一键发布（macOS / Linux）
```

---

## 一、更新一篇文章（完整闭环）

```
写 md → hugo server 预览 → .\deploy.ps1 → 服务器 git pull → 完成
```

### 1. 写文章

在对应目录新建 md（`content/fde/xxx.md`、`content/ai/xxx.md`、`content/fde/jobs/xxx.md`）：

```yaml
---
title: "文章标题"
record: "FDE-04"            # 记录号，见下表
date: 2026-11-01             # 发布日期（决定排序、sitemap、首页"新"标）
description: "一句话摘要"     # 进 meta description、列表页、内链推荐
tags: ["FDE", "AI落地"]
---

正文用 markdown 写，不要写 H1 大标题（模板自动输出）。
```

| 编号 | 用途 |
|------|------|
| FDE-01、02… | /fde/ 下的文章，按发布顺序递增 |
| FDE-J01… | /fde/jobs/ 下的岗位页 |
| AG-01… | /ai/ 下的文章 |
| PSN-01 | 关于页 |

岗位页额外加 `kind: "job"` 和公司信息（company / location / type / salary / salaryMin / salaryMax / status / companyUrl），模板自动输出 JobPosting 结构化数据和「在招」印章，参考现有三篇。

文章带 FAQ（对 GEO 有用）：front matter 加 `faq:` 列表，正文放 `{{< faq >}}`：

```yaml
faq:
  - q: "问题？"
    a: "回答。"
```

### 2. 本地预览

```powershell
hugo server          # 浏览器打开 http://127.0.0.1:1313 ，改文件自动刷新
```

### 3. 发布（一条命令完成构建+提交+双分支推送）

```powershell
.\deploy.ps1 -Message "新增 xxx 文章"
```

### 4. 服务器更新

```bash
cd /var/www/myfde && git pull
```

发布后无需任何其他操作：sitemap、RSS、结构化数据、内链、标签页全部自动更新。

---

## 二、换一台电脑（一次性配置）

新电脑只需三样：**git、hugo、GitHub 登录**。仓库 clone 下来即可完整工作。

### Windows

```powershell
# 1. 装 git（https://git-scm.com）和 hugo
winget install Hugo.Hugo

# 2. git 身份（每台电脑一次）
git config --global user.name "cuiyuhui"
git config --global user.email "你的邮箱"

# 3. GitHub 登录方式：GCM 弹窗（每台电脑一次）
git config --global credential.helper manager

# 4.（可选）如果 git push 连不上 github.com 而浏览器能打开
#    说明走了代理，给 git 配上代理（端口换成那台电脑实际的）
git config --global http.https://github.com.proxy http://127.0.0.1:7897

# 5. 克隆 + 验证 + 发布
git clone https://github.com/yhcui/myfde-site.git
cd myfde-site
hugo server                # 能打开 http://127.0.0.1:1313 就说明环境 OK
.\deploy.ps1               # 若提示脚本禁止运行，先执行一次：
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

首次 `git push` 时会弹出 GitHub 登录窗口（浏览器 OAuth），登录一次后凭据存进系统，以后不再问。

### macOS / Linux

```bash
# 1. 装 hugo
brew install hugo            # macOS
# 或 https://github.com/gohugoio/hugo/releases 下载对应版本解压到 PATH

# 2. git 身份 + 登录
git config --global user.name "cuiyuhui"
git config --global user.email "你的邮箱"
# push 时按提示在浏览器完成 GitHub OAuth 即可

# 3. 克隆 + 发布
git clone https://github.com/yhcui/myfde-site.git
cd myfde-site
hugo server
./deploy.sh "新增 xxx 文章"
```

### 什么不在仓库里（换电脑要重做的）

| 项目 | 命令 | 说明 |
|------|------|------|
| git 身份 | `git config --global user.name/email` | 不设无法 commit |
| GitHub 凭据 | 首次 push 弹窗登录 | 存在本机凭据管理器 |
| 代理设置 | `git config --global http.https://github.com.proxy …` | 仅当该机器有代理时需要 |

---

## 三、服务器操作（Ubuntu + nginx）

### 首次部署（只做一次）

```bash
# 1. 拉取站点：服务器从 Gitee 拉（国内快）；GitHub 是主仓 + 国际镜像
git clone -b deploy https://gitee.com/你的Gitee用户名/myfde-site.git /var/www/myfde

# 2. 把 deploy/nginx-myfde.conf.txt 合并进 nginx server 块
#    （保留原有 listen / ssl_certificate 行），然后：
nginx -t && systemctl reload nginx
```

### 日常更新

```bash
cd /var/www/myfde && git pull
```

### 双仓镜像说明

- 服务器**永远只拉 `deploy` 分支**（纯 HTML），服务器不装 hugo、不跑任何进程
- `deploy.ps1` / `deploy.sh` 每次**同时推送** GitHub（origin）和 Gitee（gitee）两个远程
- 写作电脑开发、clone 用 GitHub；服务器拉取用 Gitee（国内网络原因）
- Gitee 仓库是镜像：在 Gitee 网页新建空仓库 `myfde-site`（不要初始化），本地执行一次
  `git remote add gitee https://gitee.com/你的用户名/myfde-site.git` 即完成绑定

---

## 四、常见问题

| 现象 | 处理 |
|------|------|
| `git push` 卡住/超时 | 那台电脑的 git 没走代理：`git config --global http.https://github.com.proxy http://127.0.0.1:代理端口` |
| push 弹出浏览器登录 | 正常流程，登录一次即可 |
| `hugo server` 报模板错误 | hugo 版本太老，重装最新版 |
| 服务器 `git pull` 超时 | 检查 Gitee 远程是否正确：`git remote -v` 应指向 gitee.com |
| 改了文章线上没变 | 忘了跑 `deploy.ps1` 或服务器没 `git pull` |

---

## 五、SEO / GEO 维护备注

- **sitemap**：构建自动生成，lastmod 自动取 git 提交时间，永远真实
- **robots.txt**：已明确放行 GPTBot / ClaudeBot / PerplexityBot 等 AI 爬虫
- **llms.txt**：static/llms.txt 是给 AI 引擎的站点索引——**新增重要文章后手动往里面加一行链接**
- **站长平台**（一次性，都提交 `https://myfde.top/sitemap.xml`）：
  百度 https://ziyuan.baidu.com · Google Search Console · Bing Webmaster
- **备案号**：`hugo.toml` 里 `icp = ""` 填上，页脚自动显示

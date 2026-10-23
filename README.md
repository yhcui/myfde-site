# myfde.top 站点仓库

myfde.top 的源码与部署脚本。Hugo 静态站点，野战手册风格。

- `content/` 所有文章（markdown + front matter）
- `layouts/` 模板（野战手册主题，无第三方主题依赖）
- `assets/css/` 样式
- `static/` 静态文件（favicon、llms.txt）
- `deploy.ps1` 一键构建 + 推送

## 日常更新

### 写一篇新文章

1. 在对应目录新建 md 文件，例如 `content/fde/my-new-post.md`：

```yaml
---
title: "文章标题"
record: "FDE-04"          # 记录号，每篇递增，见下方编号表
date: 2026-11-01           # 发布日期（决定排序和 sitemap 日期）
description: "一句话摘要，会进 meta description 和列表页"
tags: ["FDE", "AI落地"]    # 用于相关文章推荐和标签页
---

正文支持 markdown。文章末尾不用写标题（H1 由模板输出）。
```

2. 本地预览：`hugo server`，浏览器打开 http://127.0.0.1:1313/
3. 满意后发布：`.\deploy.ps1 -Message "新增 xxx 文章"`
4. 服务器上更新：`cd /var/www/myfde && git pull`（服务器拉的是 deploy 分支，只含构建好的 HTML）

### 记录编号表

| 编号 | 用途 |
|------|------|
| FDE-01、FDE-02… | /fde/ 下的文章，按发布顺序递增 |
| FDE-J01… | /fde/jobs/ 下的岗位页 |
| AG-01… | /ai/ 下的文章 |
| PSN-01 | 关于页 |

### 岗位页

`content/fde/jobs/` 下新建 md，front matter 里带 `kind: "job"` 和公司信息（company/location/type/salary/salaryMin/salaryMax/status），模板会自动输出 JobPosting 结构化数据和「在招」印章。

### 文章带 FAQ

front matter 里加 `faq:` 列表，正文里放 `{{< faq >}}` 短代码，同时生成页面 FAQ 区块和 FAQPage 结构化数据（对 GEO 有用）：

```yaml
faq:
  - q: "问题一？"
    a: "回答一。"
```

## 首次部署（已完成的话跳过）

1. GitHub 新建公开仓库（如 `yhcui/myfde-site`），然后：

```powershell
git remote add origin https://github.com/yhcui/myfde-site.git
git push -u origin main
.\deploy.ps1        # 构建并推 deploy 分支
```

2. 服务器上（web 目录）：

```bash
git clone -b deploy https://github.com/yhcui/myfde-site.git /var/www/myfde
```

3. nginx 配置：参考 `deploy/nginx-myfde.conf.txt`（含旧 URL 301 跳转、.git 屏蔽、缓存），合并进现有 server 块后 `nginx -t && systemctl reload nginx`。

4. 站长平台提交 sitemap（一次性）：
   - 百度站长平台：https://ziyuan.baidu.com （验证文件已在线上）
   - Google Search Console：https://search.google.com/search-console
   - Bing Webmaster：https://www.bing.com/webmasters
   - 三处都提交 `https://myfde.top/sitemap.xml`

## 技术说明

- Hugo 构建，纯静态输出，服务器只有 nginx + HTML，内存占用可忽略
- `enableGitInfo = true`：sitemap 的 lastmod 自动取 git 提交时间，永远是真实日期
- robots.txt 已明确放行 GPTBot / ClaudeBot / PerplexityBot 等 AI 爬虫；`llms.txt` 供生成式引擎索引
- 新文章上线后无需任何额外操作：sitemap、RSS、结构化数据、内链全部自动更新

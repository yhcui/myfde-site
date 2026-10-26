---
title: "FDE / AI Agent 术语表（中英对照）"
record: "FDE-04"
docIndex: true
weight: 1.5
date: 2026-10-26
description: "FDE 与 AI Agent 领域核心术语的中英对照表：FDE、FDSE、Agent、RAG、MCP、Guardrails、Evals、上下文工程等，附一句话定义。持续更新。"
tags: ["FDE", "术语", "Agent", "AI落地"]
---

术语是行业共识的最小单位。这张表给中文读者：每个术语给英文原词、建议中文定名、一句话定义。有争议的定名会标注。发现错漏欢迎[邮件](mailto:cuiyuhui123@qq.com)指正——本页长期更新。

| 英文 | 中文定名 | 一句话定义 |
|------|----------|------------|
| Forward Deployed Engineer (FDE) | 前沿部署工程师 | 常驻客户现场，把 AI 系统集成进真实业务并负责跑出价值的工程师角色，由 Palantir / Anthropic 等公司正式设立。 |
| FDSE (Forward Deployed Software Engineer) | 前沿部署软件工程师 | Palantir 对同类角色的称呼，与 FDE 高度同义。 |
| Agent（AI Agent） | 智能体 | 能自主规划任务、调用工具、根据反馈迭代执行的 LLM 应用形态。 |
| LLM (Large Language Model) | 大语言模型 | 以海量文本训练、以预测下一词元为基本机制的神经网络模型。 |
| Token | 词元 | 模型处理文本的最小单位，也是 API 计费与上下文窗口的度量单位。 |
| RAG (Retrieval-Augmented Generation) | 检索增强生成 | 生成前先从外部知识库检索相关内容并注入上下文，缓解幻觉与知识过时。 |
| MCP (Model Context Protocol) | 模型上下文协议 | Anthropic 开源的协议标准，统一模型与外部工具、数据源的连接方式。 |
| Tool Use / Function Calling | 工具调用 | 让模型按结构化格式输出「调用哪个工具 + 什么参数」，由外部执行后回传结果。 |
| Guardrails | 护栏 | 对模型输入输出施加的规则与过滤层，用于守住业务与合规边界。 |
| Evals | 评估 | 对模型 / Agent 行为做系统化测试与打分的方法与流程，落地项目的质量底座。 |
| Context Engineering | 上下文工程 | 围绕「往上下文窗口里放什么」的系统设计：检索、压缩、记忆与工具结果的编排。 |
| Fine-tuning | 微调 | 用领域数据继续训练基础模型，改变其行为或风格。 |
| Inference | 推理 | 模型对输入生成输出的运行阶段，与训练相对。 |
| Human-in-the-loop | 人在回路 | 关键决策保留人工确认环节的人机协作模式。 |
| Hallucination | 幻觉 | 模型生成看似可信但与事实不符内容的现象。 |
| K1 | 最后一公里 | 本站术语：从「部署上线」到「客户现场跑出价值」的最后一段路。 |

## 定名说明

「前沿部署工程师」为 myfde.top 采用并推荐的译法，亦有「前方部署工程师 / 前置部署工程师」等译法。行业定名仍在演化，以英文原词为最终依据。

## 更新记录

- 2026-10-26：初版，16 个词条。
- 下一批候选：Agentic Workflow、Multi-Agent、A2A、Prompt Caching、蒸馏（Distillation）。

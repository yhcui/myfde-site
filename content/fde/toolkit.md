---
title: "FDE 装备库：训练资源与工具清单"
record: "FDE-08"
docIndex: true
weight: 2.1
date: 2026-11-05
description: "FDE 路线的装备清单：官方文档、课程、框架与工具的精选清单，按训练阶段对应，只收能长期信赖的一手来源。持续更新。"
tags: ["FDE", "资源", "清单", "训练"]
---

## 装备库的入选标准

只收两类东西：**一手来源**（官方文档与规范）和**经过时间检验的通用课**。不收速成营销课，不收拼凑教程——FDE 的手艺要对得起客户现场，学习材料就要用经得起追问的。清单按[训练路径](/fde/training/)的阶段对应，持续更新，发现过时条目欢迎[邮件](mailto:cuiyuhui123@qq.com)指出。

## 阶段一：调通模型（K0）

- [Anthropic 文档](https://docs.anthropic.com) / [OpenAI Cookbook](https://cookbook.openai.com)——两家官方文档都是一手实践来源，Prompt 工程章节尤其值得精读
- [Anthropic 提示词工程教程](https://github.com/anthropics/prompt-eng-interactive-tutorial)——官方交互式教程，把「怎么写指令」从玄学变成工程
- 各家 API 的定价与限制页——**读定价文档是工程的一部分**，见《[Token 经济学](/ai/token-economics/)》

## 阶段二：单 Agent 与工具（K1）

- [Model Context Protocol](https://modelcontextprotocol.io)——工具生态的协议标准，规范与 SDK 都在这（入门见《[MCP 指南](/ai/mcp-guide/)》）
- [LangChain 文档](https://python.langchain.com)——集成生态最全的框架，文档里的模式讲解比框架本身更值钱（选型讨论见《[框架怎么选](/ai/framework-chooser/)》）
- 任意一家的 function calling 官方指南——先把原生工具调用裸写一遍，再上框架

## 阶段三：知识接入（K2）

- 向量数据库各选一档入门（开源如 pgvector / 商用托管服务）——从最小的开始，别在选型上耗时间
- 《[RAG 入门](/ai/rag-intro/)》《[RAG 进阶](/ai/rag-advanced/)》——本站的管线与坑位地图

## 阶段四：质量与护栏（K3-K4）

- 《[Evals](/ai/evals-intro/)》《[Guardrails](/ai/guardrails-intro/)》《[提示词注入攻防](/ai/prompt-injection/)》——质量与安全的本站三部曲
- [OpenAI Evals / 各家评估工具库]——评估的工程化实现参考
- OWASP LLM Top 10——AI 安全是新攻击面，系统化威胁清单在这（见《[注入攻防](/ai/prompt-injection/)》）

## 通用底子

- Python 工程基础（FastAPI 官方文档）——Agent 服务的默认载体
- 一门云平台的基础认证或文档——部署是 FDE 的家常便饭
- [Hugging Face](https://huggingface.co)——模型与数据集的一手集散地，开源生态的事实中心

## 使用纪律

装备库解决「用什么」，下面的才是真功课：**每一件装备都要做出一个自己的小产出再换下一件**——读过不等于会用，用过不等于能交付。产出清单见《[求职攻略](/fde/fde-jobs-guide/)》的作品集一节。

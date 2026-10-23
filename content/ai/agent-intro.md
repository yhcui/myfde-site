---
title: "AI Agent 入门指南：从概念到实战"
record: "AG-01"
date: 2026-09-01
description: "什么是 AI Agent？它和普通 AI 对话有什么不同？这篇文章帮你理清概念，并带你用 LangChain 搭建第一个 Agent。"
tags: ["Agent", "AI", "教程", "LangChain"]
---

> 什么是 AI Agent？它和普通的 AI 对话有什么不同？这篇文章帮你理清概念，并带你搭建第一个 Agent。

## 什么是 AI Agent？

AI Agent（人工智能代理）是一种能够**感知环境、做出决策、执行动作**的智能系统。

和普通的大模型对话不同，Agent 具备三个核心能力：

1. **自主性** - 能够自己规划任务步骤，不需要人类一步步指导
2. **工具使用** - 可以调用外部工具（API、数据库、搜索引擎等）
3. **记忆能力** - 能记住上下文，在多轮对话中保持一致性

举个简单的例子：你告诉 AI「帮我订明天下午3点北京到上海的机票」，普通 AI 只能告诉你怎么操作，而 Agent 能直接打开订票网站、查询航班、完成下单。

## Agent 的核心架构

一个典型的 Agent 系统包含以下几个部分：

### 1. 大脑（LLM）

负责理解任务、推理决策。目前主流选择：

- OpenAI GPT-4/3.5
- Anthropic Claude
- 国内：通义千问、文心一言、智谱 GLM

### 2. 记忆模块

- **短期记忆**：当前对话上下文
- **长期记忆**：持久化存储用户偏好、历史经验

### 3. 工具集

Agent 的能力边界取决于它能调用什么工具：

- 搜索工具（联网搜索）
- 代码执行（运行 Python/Shell）
- API 调用（数据库、第三方服务）
- 文件操作（读写文件）

### 4. 规划能力

复杂任务需要分解成多个步骤，Agent 需要能够：

- 任务分解
- 制定执行计划
- 处理失败和重试

## 主流 Agent 框架对比

| 框架 | 特点 | 适用场景 |
|------|------|----------|
| **LangChain** | 生态完善，组件丰富 | 通用场景，快速原型 |
| **AutoGen** | 多 Agent 协作 | 复杂任务，团队协作 |
| **CrewAI** | 角色定义清晰 | 业务流程自动化 |
| **Dify** | 低代码可视化 | 快速搭建，非技术人员 |

## 快速上手：用 LangChain 搭建第一个 Agent

下面是一个简单的例子，展示如何用 LangChain 创建一个能搜索网页的 Agent：

```python
from langchain.agents import initialize_agent, load_tools
from langchain.llms import OpenAI

llm = OpenAI(temperature=0)

# 初始化工具
tools = load_tools(["serpapi", "llm-math"], llm=llm)

# 创建 Agent
agent = initialize_agent(
    tools,
    llm,
    agent="zero-shot-react-description",
    verbose=True
)

# 运行 Agent
agent.run("当前北京PM2.5是多少？如果超过100，建议什么防护措施？")
```

这个 Agent 会：

1. 先调用搜索引擎查询北京 PM2.5
2. 根据结果判断是否需要建议防护措施
3. 生成完整的回复

## 实战案例：客服 Agent

我最近帮一个客户搭建了一个客服 Agent，功能是：

1. 用户提问后，先检索知识库
2. 如果有标准答案，直接回复
3. 如果没有，调用 LLM 生成回答
4. 记录对话历史，用于后续优化

技术栈：

- 后端：Python + FastAPI
- 向量数据库：Pinecone
- LLM：GPT-3.5-turbo
- 前端：React

效果：客服响应时间从平均 5 分钟降低到 10 秒，解决率提升 60%。

## 学习路径建议

如果你想深入学习 Agent 开发，建议按这个顺序：

1. **基础** - 熟悉 Python，了解 LLM API 调用
2. **入门** - 学习 LangChain 基础，跑通简单 Agent
3. **进阶** - 学习 RAG（检索增强生成），搭建知识库问答
4. **深入** - 多 Agent 协作，复杂业务流程
5. **实战** - 找真实场景落地，积累经验

更完整的「从工程能力到现场交付」路线，见《[FDE 培训与入门路径](/fde/training/)》——Agent 是 FDE 最重要的武器，两者是一件事的两面。

## 推荐资源

- [LangChain 官方文档](https://python.langchain.com/)
- [AutoGen GitHub](https://github.com/microsoft/autogen)
- [OpenAI API 文档](https://platform.openai.com/docs/)
- [AI Agent 论文合集](https://arxiv.org/list/cs.AI/recent)

---

*后续我会持续更新 Agent 相关的实战教程，FDE 路线的更多记录见 [FDE 主题页](/fde/)。*

---
title: "MCP：让 AI 接上你的系统"
record: "AG-03"
date: 2026-11-05
description: "MCP（Model Context Protocol）是什么、解决什么集成问题、三层架构与三类原语，和一个最小可运行的代码示例。工程师视角，五分钟读完。"
tags: ["MCP", "Agent", "教程", "协议"]
---

## 一句话

MCP（Model Context Protocol，模型上下文协议）是 [Anthropic](https://www.anthropic.com) 于 2024 年 11 月开源发布的协议标准，用来让 AI 应用以统一的方式连接外部工具与数据源——目前已被主流模型厂商与开发工具采纳，事实上的行业标准。规范与 SDK 见 [modelcontextprotocol.io](https://modelcontextprotocol.io)。

## 它解决什么问题

没有 MCP 之前，接工具是这样的：

- 每个模型/客户端一套 function calling 格式，同一把「查天气」要在 Claude、ChatGPT、各家 IDE 插件里各写一遍；
- N 个客户端 × M 个工具 = **N × M** 份集成代码，谁都没有动力重复维护。

MCP 把「能力」从客户端里抽出来，做成独立进程（Server），双方只对协议负责：

- 任何客户端（Host）都能连任何 Server；
- N × M 变成 **N + M**——写一次，处处可挂。

这是 USB 接口的历史重演：接口标准化之后，外设生态爆发。

## 三层架构

| 角色 | 是什么 | 例子 |
|------|--------|------|
| **Host** | 用户所在的 AI 应用 | 桌面助手、IDE 插件、你的业务系统 |
| **Client** | Host 内维护的协议端点，一比一连一个 Server | Host 进程里的连接管理 |
| **Server** | 独立进程，对外暴露能力 | 文件系统、数据库、内部 API 的适配层 |

Server 只暴露**三类原语**，够用且克制：

1. **Tools**：可执行的动作（查库、发单、算数）——由模型决定何时调用；
2. **Resources**：可读取的数据（文件、记录）——类似只读文件；
3. **Prompts**：预置的提示词模板。

## 和 Function Calling 是什么关系

最容易混淆的一对概念，一张表分清：

| | Function Calling | MCP |
|---|---|---|
| 层级 | 模型能力：模型**决定**要调用什么 | 生态协议：工具**挂在哪**、怎么发现 |
| 范围 | 单个应用内部 | 跨应用、跨厂商复用 |
| 关系 | 模型用 FC 决策，通过 MCP 协议去执行 | 二者是上下游，不互相替代 |

## 最小可运行示例

用官方 Python SDK 写一个查询内部数据的 Server（先 `pip install "mcp[cli]"`）：

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("ops-tools")

@mcp.tool()
def get_ticket_status(ticket_id: str) -> str:
    """查询工单当前状态"""
    # 真实场景里这里是查内部系统
    return f"工单 {ticket_id}：处理中，预计 2 小时完成"

mcp.run()   # 默认 stdio 传输
```

任何支持 MCP 的客户端配置这个 Server 后，用户说「帮我看下工单 1234」，模型会自己决定调用 `get_ticket_status`。你**没有为任何特定模型写一行集成代码**——这就是 N+M 的含义。

## 什么时候不用 MCP

协议有成本，小场景别上：

- 单个应用内部、只有一两个工具——直接 function calling 更简单；
- Server 意味着独立进程与权限边界，安全设计（这个 Server 能碰哪些数据）要想清楚，工具即权限；
- 生态仍在快速演化，规范细节可能变——跟着 [modelcontextprotocol.io](https://modelcontextprotocol.io) 的版本走，别背死细节。

## 小结

对要落 AI 的人来说，MCP 的意义不在协议细节，而在它改变了岗位技能结构：**「把模型接入企业系统」正在变成拼装标准件，而不是每次都手搓集成**。会用、会评估、会给它加安全边界的工程师，正是 FDE 路线上最值钱的那段 K1。

相关术语见[术语表](/fde/glossary/)。

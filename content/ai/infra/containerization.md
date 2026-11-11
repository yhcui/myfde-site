---
title: "容器化部署 AI 服务：从 Dockerfile 到编排"
record: "INF-18"
date: 2026-11-05
description: "推理服务的容器化要点：权重挂载 vs 打进镜像的取舍、GPU 运行时、多卡环境、编排清单与一个最小 compose 起手式。"
tags: ["Infra", "容器", "Docker", "部署", "私有化"]
---

## 先想清楚：权重放哪

AI 服务容器化与普通服务的第一区别是**权重文件怎么处理**：

| 方案 | 优点 | 代价 |
|------|------|------|
| 权重打进镜像 | 部署即用、版本强一致 | 镜像几十 GB 起步，分发/存储负担重 |
| **权重挂载（volume）** | 镜像小、换模型不动镜像 | 启动校验依赖台账（见《[模型分发](/ai/infra/model-distribution/)）） |

经验值：**镜像放代码与环境，volume 放权重**——镜像层管理依赖版本，权重层管资产台账，两套纪律各管各的。唯一例外是完全离线交付的一体化包（见《[离线部署](/ai/infra/air-gapped/)》），整包导出时权重的校验和必须进交付清单。

## GPU 运行时

容器里用 GPU 靠运行时直通：

- NVIDIA Container Toolkit 是事实标准：装驱动（宿主机）→ 装容器运行时钩子 → 容器里直接可见 GPU；
- **驱动装宿主机，CUDA 库随镜像**——这对版本组合就是你的「驱动/CUDA/运行时矩阵」，离线场景里提前验证（见《[硬件选型](/ai/infra/hardware-choice/)》）；
- 多卡：容器声明可见的卡数；大模型张量并行时容器内可见多卡，环境变量与拓扑要对齐 NUMA/亲和性——**这类问题现场排查极其耗时，编排文件里写死，别靠默认值**。

## 编排清单

- 镜像：锁 digest 而不是 tag（tag 会被悄悄覆盖）；
- 健康检查：探针打到推理端点，**就绪探针要等权重加载完**（分钟级，别抄 Web 服务的秒级超时）；
- 资源：显存不可超卖——单机多容器抢显存是慢性事故（见《[显存账本](/ai/infra/vram-ledger/)》）；
- 重启策略 + 优雅停止：推理请求耗时长，给足 drain 时间；
- 日志：容器 stdout 走收集，GPU 相关指标另外接 exporter（见《[GPU 监控](/ai/infra/gpu-monitoring/)）。

## 最小 compose 起手式

```yaml
services:
  llm:
    image: <你的推理镜像>@sha256:...
    volumes:
      - ./models:/models        # 权重挂载
    environment:
      - MODEL=/models/xxx-awq
    deploy:
      resources:
        reservations:
          devices: [{capabilities: [gpu]}]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 10               # 权重加载慢，给够次数
      start_period: 180s
```

起点就这么朴素：单机 compose 跑稳，等真有集群规模需求再上 K8s——**规模没到就上重编排，是用别人的复杂度换自己的加班**（伸缩话题见《[弹性伸缩](/ai/infra/autoscaling/)》）。

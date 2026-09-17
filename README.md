<h1 align="center">firstmate</h1>
<p align="center">
  <a
    href="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue?style=flat-square"
    ><img
      alt="Platform"
      src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue?style=flat-square"
  /></a>
  <a href="https://x.com/kunchenguid"
    ><img
      alt="X"
      src="https://img.shields.io/badge/X-@kunchenguid-black?style=flat-square"
  /></a>
  <a href="https://discord.gg/Wsy2NpnZDu"
    ><img
      alt="Discord"
      src="https://img.shields.io/discord/1439901831038763092?style=flat-square&label=discord"
  /></a>
</p>

> [!NOTE]
> 本项目 fork 自 [kunchenguid/firstmate](https://github.com/kunchenguid/firstmate)，主要文档已翻译为中文。
> 本 fork 计划支持的 agents：**Codex、ZCode、Qoder、CodeBuddy**（不再包含 Claude Code）。

<h3 align="center">与一名代理对话，让一支船队为你交付。</h3>

<p align="center">
  <img alt="firstmate - talk to one agent, ship with a crew" src="assets/banner.png" width="100%" />
</p>

## 这是什么

一个人跑起一个编码代理并不难。
可一旦你想同时推进三个项目任务，比如修缺陷、做调查、出方案、做审计，你就会变成标签页杂耍演员：看守着一堆会话，在仓库之间复制粘贴上下文，还要记住哪个终端里躺着那个失败的测试。

firstmate 把这个模型倒了过来。
你只和一名代理对话，也就是大副，由它替你指挥船队：在可见的会话后端里启动自主代理，给每个代理一个干净的 git worktree，监督它们直到完成，最后把做好的 PR、已批准的本地合并或独立的调查报告交到你手上。
对于更大的船队，你可以选择启用常驻二副（secondmates）：它们仍是普通的直接下属，但运行在自己的隔离 firstmate 主目录中，位置可以在本机，也可以在另一台 SSH 可达的主机上。

firstmate 不是模型，不是 harness，不是技能，不是 MCP 服务器，也不是 CLI。
firstmate 是一个用来指挥一支代理船队的代理发行版（agent distro）。
代理发行版是一个可移植的目录，包含指令、技能、工具、策略和状态约定，能把一个通用代理改造成专用代理。
没有需要安装的应用：克隆下来的仓库就是发行版本身 - `AGENTS.md`、内置的 firstmate 技能，以及任何终端编码代理都能照办的辅助脚本。
在其中为你的主会话启动一个受支持的 harness，就实例化了你的大副 - 也让你成为船长。

## 特性

- **单一联络人** - 你只和大副对话；它负责派活、监督，只在真正需要决策时上报，并以平实的结论汇报。
- **可见的船员** - 每名船员都在自己的 tmux 窗口、Herdr 标签页，或实验性的 zellij 标签页、cmux 工作区、Orca 终端里工作，你可以旁观也可以插话；由大副负责对账。
- **一次性的 worktree** - 每个任务都运行在干净的 [treehouse](https://github.com/kunchenguid/treehouse) git worktree 里（`backend=orca` 时则是 Orca 管理的 worktree），同一仓库上的并行工作互不冲突。
- **两种任务形态** - ship 任务交付已授权的变更；scout 任务在接收契约确有需要时留下独立的调查报告。
- **显式的项目模式** - 每个项目通过 `no-mistakes`、`direct-PR` 或 `local-only` 交付，并可附加可选的 `+yolo` 合并自治开关。
- **可选的二副** - 可选择启用常驻二副：它们运行在拥有自己的 `FM_HOME`、状态、项目和会话锁的隔离 firstmate 主目录中，既可以是本机的，也可以是 SSH 可达主机上的完整主目录；更新与恢复都有防护，绝不会把不可用的远程通道悄悄换成本地替代。
- **事件驱动、零 token 的监督** - 一个 bash 看护进程守着船队休眠，只在需要你时才唤醒大副；受支持的主 harness 还配有回合结束兜底，在工作进行中而监督不在线时，阻止或跟进无人看守的停止。
- **可选的 Relay** - 在本地 `.env` 里放一个配对 token 即可启用，让 firstmate 能同时回应你在 X 和 Discord 上的公开提及，以与聊天请求相同的生命周期处理常规可逆的提及请求，确认被派出的工作，并为真正的里程碑和最终结果在七天内发布至多三条公开安全的完成跟进；在线程里许诺的最终回复会落成磁盘上的持久状态并据其对账，因此重启或上下文压缩都不会弄丢它；上线前可用 dry-run 在本地预演将要发出的回复与折叠操作。
- **严格的项目边界** - 大副对你的项目只读，仅有[硬规则 1](AGENTS.md#1-identity-and-prime-directives) 授权的少数受防护且经船长批准的操作例外（包括 fleet sync 有防护的安全分支清理）；其余所有项目变更都由船员在既定的合并授权之下完成。
- **重启无碍** - 所有状态都存放在磁盘和活跃的会话后端中（硬默认 tmux，被选中或自动检测时为 herdr 或 cmux，显式选择时为 zellij 或 orca）；随时杀掉会话，下一个会话会完成对账（包括确认已死的二副代理），然后继续前进。

每项特性的完整细节见 [docs/architecture.md](docs/architecture.md)。

## 快速开始

<a name="requirements"></a>
### 环境要求

- 本 fork 计划支持的主代理：Codex、ZCode、Qoder 和 CodeBuddy；其中 Codex 已可用，其余适配中。
- Git 和 GitHub CLI，并通过 `gh auth login` 完成认证。
- 你所选运行后端的 CLI 及其依赖；tmux 是参考默认。

大副会检测受支持的缺失工具，在你批准后才安装。
后端专属设置链接在[文档](#文档)一节。

### 代理支持计划

本 fork 后续计划支持的 agents 为 **Codex、ZCode、Qoder 和 CodeBuddy**，不再包含 Claude Code。
其中 Codex 沿用上游已验证的支持；ZCode、Qoder 和 CodeBuddy 的适配在计划中，落地后会在本节补充各自的用法与验证状态。

### 安装与启动

```sh
gh auth login
git clone https://github.com/kunchenguid/firstmate
cd firstmate
```

然后启动你选择的主代理；从这一刻起由 AGENTS.md 接管：

**Codex**

```sh
codex
```

ZCode、Qoder 和 CodeBuddy 的启动方式将随适配进度在本节补充。

### 和它对话

```sh
> ahoy! 看看我的 GitHub 项目 xyz，把那个不稳定的登录测试修好，再加上深色模式

# firstmate 检查自己的工具链（安装任何东西前先征得你的同意），
# 在 projects/ 下克隆该项目，并在当前后端中启动两个相互隔离的 worker。
# 几分钟后：

  PR 已就绪待审，船长：https://github.com/you/xyz/pull/42
  （修复不稳定的登录测试 - 风险：低 - CI 全绿）

> 好，合并吧
```

### 更多后端

tmux（默认）以及所有其他受支持后端（herdr、zellij、Orca、cmux）的设置指南，都链接在下方的[文档](#文档)一节。

## 工作原理

```
            你（船长）
                  │  聊天：请求、决策、"合并它"
                  ▼
 ┌─────────────────────────────────────┐
 │ firstmate（本仓库）                 │
 │ 读取 projects/，firstmate 负责路由  │
 │ 有防护地写入 backlog/简报/状态       │
 └──┬──────────────┬───────────────┬───┘
    │ 后端发来 / 状态文件 │
    ▼              ▼               ▼
 ┌────────┐   ┌────────┐      ┌────────┐
 │fm-task1│   │fm-task2│  ... │fm-taskN│   tmux 窗口、herdr/zellij 标签页、cmux 工作区或 Orca 终端
 │ 船员   │   │ 船员   │      │ 船员   │   每格一个自主代理
 └───┬────┘   └───┬────┘      └───┬────┘
     ▼            ▼               ▼
  treehouse worktree、Orca worktree 或隔离的二副主目录
     │
     ├─ ship：项目模式 ► PR/本地合并 ► 清理
     │
     └─ scout：报告写入 data/<id>/report.md ► 决策盘点 ► 转达发现 ► 清理
```

你与大副对话。
它把每个请求路由到拥有独立会话端点和 git worktree 的船员，用一个零 token 的事件驱动看护进程监督整支船队，然后把做好的 PR、已批准的本地合并或调查报告交给你。
可选的二副把这一模式扩展为常驻的本机或整机远程二副；派发档案（dispatch profiles）让你指定哪个任务用哪个 harness；可选启用的 Relay 则让同一支船队回应公开提及。
`codex-app` 还不是运行后端；[docs/codex-app-backend.md](docs/codex-app-backend.md) 负责 Codex App 边界的界定。

完整架构（监督引擎、worktree 隔离、二副、派发档案、项目模式、可选 Relay、fleet sync 与自更新）见 [docs/architecture.md](docs/architecture.md)。

## 内置技能

Firstmate 自带以下可由用户调用的内置技能。
支持斜杠命令的代理使用这里展示的 `/` 形式；codex 使用相同名称的 `$` 形式，例如 `$afk`。

| 技能               | 作用                                                                                                                                          |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `/afk`             | 进入离开模式监督：子监督者在 bash 中自行处理常规通知，把与船长相关的事件和有界声明的外部等待复检聚合成摘要上报，在你离开期间若交付卡住会主动报警 |
| `/quiet`           | 进入安静监督模式：与 `/afk` 相同的省 token 子监督者取舍，适合留在原地继续聊天的船长；普通消息不会退出该模式，只有显式的 `/quiet off` 才会        |
| `/ahoy`            | 回顾自上一条真实船长消息以来可见的会话事件，以及明显未获回应的船长决策，然后按代理判定的影响顺序逐条引导船长处理未决决策；当它作为本会话第一条真实船长消息被调用时，退化为 Bearings |
| `/bearings`        | 从有界的舰队状态生成简洁的四段式聊天摘要，包括已注册的远程主目录台账和对自己发起的贡献的实测跟进；用 `/bearings file` 还会替换 `data/` 下今天的日期报告，加 `include PRs` 可启用全仓库实时 PR 增强 |
| `/updatefirstmate` | 有防护地更新运行中的 firstmate 及其二副 - 快进，或对齐 squash 合并后的冗余分叉 - 然后持久化并重启每个成功留在目标提交上的活跃伙伴（包括已是最新的主目录），只有在无法证明重启成功时才给出诚实的重读提示 |
| `/stow`            | 扫描本会话中未沉淀的持久知识，持久化本会话已知未归档或现已失真的进行中工作记录，以衰减和冷归档的方式策展分层启动记忆，执行每个主目录的预算或呈现所需的决策，级联到已注册的二副，并报告哪些内容可以安全重置 |

Bearings 调用示例：

- `/bearings` 只在聊天里返回最新的四段式摘要。
- 自有贡献的跟进来自缓存的覆盖投影；`include PRs` 仍是启用全仓库实时 PR 增强的可选开关。
- `/bearings include PRs` 保持纯聊天模式，并选择加入实时 PR 增强。
- `/bearings file` 从零重建今天的 `data/status-report-<YYYY-MM-DD>.md`，并在四段式聊天摘要中链接它。
- `/bearings file include PRs` 把日期报告与实时 PR 增强结合。

仅代理使用的参考技能位于 `.agents/skills/`，firstmate 会按 [`AGENTS.md`](AGENTS.md) 点名的触发条件加载它们。

### 两层技能布局

Firstmate 的技能存放在两个面向不同读者的位置：

- `.agents/skills/` - 由代理加载的技能（本节表格中的技能，以及 firstmate 仅代理使用的参考技能）。
  其中每一个都假设存在一个活跃的 firstmate 主目录，装到别处要么毫无意义，要么会主动误导，因此每个技能的 frontmatter 都带有 `metadata.internal: true`。
  该标志会让它们从安装器的发现中隐藏（例如 [skills.sh](https://skills.sh) 的 `npx skills add` 安装器），同时不影响 firstmate 自身的加载方式 - frontmatter 元数据对代理自己的技能加载器是惰性的。
- `skills/` - 面向安装器的公开独立技能，可单独安装进任何项目，不依赖 firstmate。
  每个都是自包含技能，不依赖 firstmate 的路径、工具或词汇。
  目前是 `skills/stow`：一个通用的会话知识清扫技能，按显式指令优先、其次既有本地约定、最后私有 `.stow-notes.md` 兜底的顺序路由发现，并通过衰减、本地归档和经用户批准的按需卸载提案来策展分层条目。
  它有意与其同名的 firstmate 内部技能 `.agents/skills/stow` 不共享任何代码，因此两者可以独立演进。

## 文档

- [docs/architecture.md](docs/architecture.md) - 船员、监督、worktree、二副与项目模式的维护者架构。
- [docs/configuration.md](docs/configuration.md) - 环境变量、`FM_HOME`、运行后端选择、可选 Relay 及其 X 和 Discord 设置步骤、可信外部 process-event 适配器设置、需要你创建的文件，以及 harness 支持。
- [docs/extension-bindings.md](docs/extension-bindings.md) - 窄口径可信外部 `process-event-adapter/1` 包、绑定、握手与证据边界的维护者架构。
- [docs/remote-secondmates.md](docs/remote-secondmates.md) - 整机远程二副的当前设置、路由、转移、恢复与安全行为。
- [docs/voice-relay.md](docs/voice-relay.md) - 可选的语音接口：两台机器上的设置、实测往返成本、语音回答可以读到什么，以及本版本尚不做什么。
- [docs/wedge-alarm.md](docs/wedge-alarm.md) - 为卡住的离开模式升级投递配置主动告警。
- [docs/tmux-backend.md](docs/tmux-backend.md) - tmux 参考后端的当前设置与限度。
- [docs/herdr-backend.md](docs/herdr-backend.md) - Herdr 后端的当前设置、CI 覆盖、安全边界与限度。
- [docs/zellij-backend.md](docs/zellij-backend.md) - 实验性 Zellij 后端的当前设置与限度。
- [docs/orca-backend.md](docs/orca-backend.md) - 实验性 Orca 后端的当前设置与限度。
- [docs/cmux-backend.md](docs/cmux-backend.md) - 实验性 cmux 后端的当前设置、套接字安全与限度。
- [docs/codex-app-backend.md](docs/codex-app-backend.md) - 当前受阻的 Codex App 后端边界与上线契约。
- [docs/verification/runtime-backends.md](docs/verification/runtime-backends.md) - 运行后端保证的活跃维护者验证。
- [docs/gitlab-merge-watch.md](docs/gitlab-merge-watch.md) - 在任意实例上监视并合并 GitLab merge request 的维护者验证。
- [docs/turnend-guard.md](docs/turnend-guard.md) - 主会话当前"没有回合盲停"兜底的范围、循环安全与兼容限度。
- [docs/verification/supervision.md](docs/verification/supervision.md) - 会话启动、兜底、连续性与卡住告警集成的活跃维护者验证。
- [docs/supervision-protocols/](docs/supervision-protocols/) - 各主代理看护协议的已渲染版本，含未知 harness 的兜底协议。
- [docs/scripts.md](docs/scripts.md) - `bin/` 工具带参考。
- [docs/documentation-audiences.md](docs/documentation-audiences.md) - 文档读者分类与机器校验的落位边界。
- [`AGENTS.md`](AGENTS.md) - 监督契约、角色边界与条件性流程的路由索引。
- [CONTRIBUTING.md](CONTRIBUTING.md) - 如何参与贡献，包括开发与测试命令。

## 参与贡献

欢迎贡献 - 工作流、仓库约定与测试运行方法见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

MIT - 见 [LICENSE](LICENSE)。

## Star History

<a href="https://www.star-history.com/?repos=kunchenguid%2Ffirstmate&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunchenguid/firstmate&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunchenguid/firstmate&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunchenguid/firstmate&type=date&legend=top-left" />
 </picture>
</a>

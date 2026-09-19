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
      src="https://img.shields.io/badge/discord-join-black?style=flat-square"
  /></a>
</p>

> [!NOTE]
> 本仓库是 [kunchenguid/firstmate](https://github.com/kunchenguid/firstmate) 的个人 fork。
> 上游的完整介绍与架构背景以上游仓库为准。
> 本 README 面向本 fork 的使用者，给出让它真正跑起来的安装、配置与上手路径。
> 本 fork 保留的本地操作文档：[配置](docs/configuration.md)、[tmux](docs/tmux-backend.md)、[Herdr](docs/herdr-backend.md)、[Zellij](docs/zellij-backend.md)、[Orca](docs/orca-backend.md)、[cmux](docs/cmux-backend.md)、[远程二副](docs/remote-secondmates.md)、[卡滞告警](docs/wedge-alarm.md)、[文档读者分类](docs/documentation-audiences.md)。

## 本 fork 的代理支持

本 fork 只支持以下四种代理，`bin/fm-spawn.sh` 会在两条选择路径上拒绝其余所有适配器名：

- **Codex** - 沿用上游已实机验证的适配，是本 fork 唯一可运行二副（secondmate）的代理。
- **ZCode** - ZCode 桌面应用实际自带 CLI（macOS 上位于 `/Applications/ZCode.app/Contents/Resources/glm/zcode.cjs`，默认不装进 PATH），firstmate 会先找 PATH 再解析捆绑路径；会话检测（`ZCODE_*` 环境标记与 `zcode-cli`/`zcode-host-*`/`ZCode` 进程名）已于 2026-09-17 在真实 ZCode 3.12.3 会话中实测。面板级行为（自动提交、忙碌状态、中断/退出）验证待做。
- **Qoder** - 已按其 CLI 帮助面完成适配（位置参数初始提示、`--dangerously-skip-permissions`、`--model`、`--reasoning-effort`），面板级行为验证待做。
- **CodeBuddy** - 已按其 CLI 帮助面完成适配（位置参数初始提示、`-y`、`--model`），注意其帮助文本声明 HIGH/CRITICAL 权限仍会询问；面板级行为验证待做。

ZCode、Qoder、CodeBuddy 三者均为船员/侦察（crewmate/scout）适配器，暂不能作为二副运行（尚无主代理监督协议）。

## 快速上手

firstmate 跑在你的编码代理里：你（船长）在主代理会话里用自然语言交代任务，它负责建档、把任务派发到隔离工作树里的船员并全程盯梢，代码改动通过 PR 交付。
本 fork 的任务派发只认 Codex、ZCode、Qoder、CodeBuddy 四个代理，默认运行后端是 tmux。

### 1. 装好前置工具

以下命令以 macOS（Homebrew）为例。
Linux 用户把 `brew` 换成对应包管理器即可。

```sh
# 基础工具与 GitHub 登录
brew install node git gh jq tmux
gh auth login

# 任务工作树提供者（treehouse）
curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh

# 交付校验管线（no-mistakes）
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh

# axi 系列（npm 全局包）
npm install -g gh-axi && gh-axi setup hooks
npm install -g chrome-devtools-axi && chrome-devtools-axi setup hooks
npm install -g tasks-axi
npm install -g quota-axi

# 选装：视觉演示（不装只影响可视化决策与报告，非可视工作不受阻）
npm install -g lavish-axi && lavish-axi setup hooks
```

再装好并登录至少一个受支持代理的 CLI：Codex（`codex`）、ZCode（桌面应用自带，默认不在 PATH 也能被找到）、Qoder（`qoder`）或 CodeBuddy（`codebuddy`）。

不想装 `tasks-axi` 的极简路径：把 `manual` 写进本地 `config/backlog-backend` 文件，待办队列改为手动编辑。

### 2. 启动第一个会话

```sh
git clone <本 fork 地址> firstmate && cd firstmate
```

在仓库目录里用主代理开启会话，推荐 Codex（本 fork 唯一经过实机完整验证、可运行二副的代理）。
会话开场应出现启动摘要；如果当前代理不会自动执行，就手动跑一次：

```sh
bin/fm-session-start.sh
```

启动摘要里的 bootstrap 段会逐项检测缺失或过旧的工具，并打印与上表一致的精确安装命令，自动安装只在你明确同意后发生。
看到 `MISSING:` 行按提示补装工具，看到 `TANGLE:` 行按提示把仓库切回默认分支即可。

### 3. 注册项目并派活

- 对 firstmate 说"添加项目 <git 仓库地址>"，它会把项目克隆进 `projects/` 并登记到项目注册表。
- 之后直接用自然语言交代任务：每个任务会在自己的隔离工作树里进行，完成后以 PR 交付并汇报 URL。
- PR 合并由你逐个拍板；也可以为项目开启 `yolo` 常态授权，让绿色且在范围内的 PR 自动合并。

### 4. 常用配置（全部本地、gitignored）

| 文件 / 变量 | 作用 | 缺省行为 |
| --- | --- | --- |
| `config/crew-harness` | 船员/侦察用哪个代理，可填 `codex`、`zcode`、`qoder`、`codebuddy` | 与主代理一致 |
| `config/secondmate-harness` | 二副代理，可带模型与推理档位 | 目前仅 `codex` 支持二副 |
| `config/backend` | 任务窗口后端：`tmux`、`herdr`、`zellij`、`orca`、`cmux` | `tmux` |
| `config/crew-dispatch.json` | 按任务类型挑选代理/模型/推理档位的自然语言规则 | 不启用 |
| `.env` 的 `TYPESAFE_API_KEY` | 类型化分派解析 | 不启用 |
| `.env` 的 `FMX_PAIRING_TOKEN` | Relay（X/Discord 公开提及）接入 | 关闭 |
| `FM_HOME` | 同一仓库跑多个实例时各自的私有数据目录 | 仓库根目录 |

各文件的精确 schema 与字段语义以 [docs/configuration.md](docs/configuration.md) 为准。

## 许可证

MIT - 见 [LICENSE](LICENSE)。

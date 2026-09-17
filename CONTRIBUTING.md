# 贡献指南

感谢你有意贡献。
先说一条规则：

**由人类提交的、指向 `main` 的 pull request 必须通过 [`no-mistakes`](https://github.com/kunchenguid/no-mistakes) 提出。**
我们要求这一点，是为了减轻维护者审查和合并贡献的负担。

`no-mistakes` 在你的真实远端前面放了一个本地 git 代理。
通过它推送时，它会在一个隔离的 worktree 里运行 AI 驱动的审查/测试/lint 流水线，全部检查通过后才把推送转发到上游，并自动开出一个干净的 PR。

一个 GitHub Actions 检查（`Require no-mistakes`）会在指向 `main` 的 PR 上运行，要求同时具备确定性签名和来自 no-mistakes v1.46.0 或更新版本的可解析结构化证明（attestation）。
该证明必须绑定当前 PR 的 head 提交，并把审查、测试、文档步骤报告为已完成；因此过期的证明、缺失的 `head_sha` 或被跳过的必需步骤都会失败。
它对每一次 PR 开启和正文编辑独立评估，在 head 同步或重新打开后重跑，并防止后来的编辑替换掉先前待定的合规检查。
GitHub Actions 和 Dependabot 豁免，它们的自动化照常工作；但不满足该证明契约的其他贡献者 PR 不会被审查或合并。

## 工作流

1. Fork 本仓库，然后克隆父仓库，或把你本地的 `origin` 指回父仓库（`git@github.com:kunchenguid/firstmate.git`）。
2. 建分支并完成你的修改。
3. 以你的 fork 作为推送目标初始化门禁：`no-mistakes init --fork-url git@github.com:<you>/firstmate.git`（向 firstmate 贡献需要 **no-mistakes v1.46.0+** 才能产出结构化证明；没有 fork 时，拥有推送权限的维护者仍可直接 `no-mistakes init`）。
4. 提交你的修改。
5. 通过门禁推送，而不是直接推到 `origin`：

   ```sh
   git push no-mistakes
   ```

6. 运行 `no-mistakes` 接入流水线，查看发现、授权自动修复，并按需审查 ask-user 发现。
   门禁机制以已安装 no-mistakes 版本的 SKILL.md 和实时 `axi` 帮助为准。
7. 流水线通过后，它会替你把分支推到你的 fork，并开出一个指向父仓库的 PR。

完整的首次运行 walkthrough 见 [no-mistakes 快速开始](https://kunchenguid.github.io/no-mistakes/start-here/quick-start/)。

## 仓库约定

- 本仓库是运行 firstmate 编排代理的模板。
  [`AGENTS.md`](AGENTS.md) 负责监督契约、角色边界和内置 firstmate 技能的触发点；`CLAUDE.md` 是指向它的真实 `@AGENTS.md` 指针，`.claude/skills` 是指向 `.agents/skills` 的符号链接。
- 只有共享材料被跟踪：`AGENTS.md`、`README.md`、`CONTRIBUTING.md`、`.tasks.toml`、`.github/workflows/`、`bin/`、`.agents/skills/` 和 `skills/`。
  `.agents/skills/` 存放由代理加载的技能，它们假设存在一个活跃的 firstmate 主目录，并带有 `metadata.internal: true`，使 [skills.sh](https://skills.sh) 之类的安装器将其从发现中隐藏；`skills/` 存放独立、面向安装器的公开技能，不依赖 firstmate（见 README 的"两层技能布局"）。
  `.claude/mods/` 存放 Claude Code mods，即行为全部位于一个 function-hooks 模块中的插件；每个 mod 都经由 `.agents/skills/<mod>` 符号链接被访问，因为 Claude Code 只从 `.claude/skills` 采纳项目插件；它们不带 `SKILL.md`，因此其他所有 harness 的技能加载器都会忽略该条目；并且只 import 物理位于自己文件夹内的文件，因为 Claude Code 拒绝其他任何来源。
  模块可以经由 `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS` 或 Claude Code 的 `tengu_plugin_hooks_modules` 灰度标志加载，但 Calm mod 只在 `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS` 恰为 `1` 时激活，其余情况完全是空操作；Firstmate 绝不在任何 settings 文件里设置该变量，契约由 [`docs/calm.md`](docs/calm.md) 负责。
  一位船长船队的一切私有内容（`.env`、`data/`、`state/`、`config/`、`projects/`、`.no-mistakes/`）都被 gitignore；绝不提交它们。
  根目录 `.tasks.toml` 是 `data/backlog.md` 的受跟踪 `tasks-axi` 配置；兼容的 `tasks-axi` 是例行 backlog 变更的默认后端，兼容性定义由 [`docs/configuration.md`](docs/configuration.md)（"Backlog backend"）负责。
  本地 `config/backlog-backend=manual` 选项强制 firstmate 的例行 backlog 更新改为手工编辑，保持 gitignored；经过验证的二副交接仍通过 `tasks-axi mv` 委派。
  本地 `config/backend` 文件为新任务端点显式覆盖运行时自动检测，保持 gitignored；spawn 支持的值是 `tmux`、`herdr`（有自己的必需 CI 泳道），以及仍属实验性、没有专属真实后端 CI 泳道的 `zellij`、`orca` 和 `cmux`；`codex-app` 仅在 `docs/codex-app-backend.md` 中记录。
  它不会让 `data/` 变成被跟踪的。
- `bin/` 中的辅助脚本是纯 bash。
  每个都以用法头注释开始；行为变更时保持其准确。
  `tests/` 中的测试脚本和辅助工具也是纯 bash。
  `bin/fm-lint.sh` 必须通过：它是 lint 定义的唯一所有者（shellcheck 文件集、配置、固定的 shellcheck 版本、固定的 actionlint workflow lint，以及拒绝核心 `bin/` 脚本直接调用 Beads CLI 的后端纯度检查），CI 和 no-mistakes 推送前门禁都不带参数地调用它。
  其头注释和 `--help` 输出负责确切的本地 lint 模式、文件集选择和分析标志。
  格式错误的 `.github/workflows/*.yml`（包括自损坏的 `ci.yml`）会在合并前让该本地 lint 路径失败，因为损坏的 workflow 无法报告自身的损坏。
  它固定一个确切的 shellcheck 版本和一个确切的 actionlint 版本，并拒绝在其他任何版本下运行。
  用 `bin/fm-lint.sh --required-version` 打印 shellcheck 固定版本，用 `bin/fm-lint-workflows.sh --required-version` 打印 actionlint 固定版本。
  用 `bin/fm-install-shellcheck.sh` 和 `bin/fm-install-actionlint.sh` 在本地安装这些确切构建；每个安装器的头注释负责其目标位置用法和支持的平台。
- harness 适配器的所有权分布如下：`bin/fm-harness.sh` 负责检测，`bin/fm-spawn.sh` 负责启动与钩子机制，`bin/fm-claude-trust.sh` 负责 spawn 期的 Claude workspace-trust 与外部 CLAUDE.md import 预批准，`bin/fm-busy-lib.sh` 负责语义忙碌源与信任门，`bin/fm-composer-lib.sh` 负责仅投递的渲染兜底，`bin/fm-teardown.sh` 负责清理，事实则保存在以 `.agents/skills/harness-adapters/SKILL.md` 为根的技能树里；依赖这些 harness 的检查的验证策略由 `firstmate-coding-guidelines` 技能负责。
- 运行时会话后端（`bin/fm-backend.sh`、`bin/backends/` 及经它们派发的脚本）的变更，把当前设置与限度保留在相关后端指南中，把活跃实证证据保留在 [`docs/verification/runtime-backends.md`](docs/verification/runtime-backends.md)。
- [`docs/documentation-audiences.md`](docs/documentation-audiences.md) 及其机器消费的清单负责行文分类；文档变更后运行 `bin/fm-doc-audience-check.sh`。
- 在 Markdown 中，每个完整句子独占一行。
- `README.md` 保持为简明概述加指针：它绝不携带大段内联细节。
  细节路由到最具体的 `docs/` 文件（架构、配置或某个后端指南），并改为链接过去。

## 开发

对 firstmate 本身的受跟踪变更 - `AGENTS.md`、`README.md`、`CONTRIBUTING.md`、`.tasks.toml`、`.github/workflows/`、`bin/`、`.agents/skills/` 和 `skills/` - 通过 `no-mistakes` 流水线在特性分支上交付，并需要显式的合并批准。
做任何此类变更之前，加载仅代理使用的 `firstmate-coding-guidelines` 技能（`.agents/skills/firstmate-coding-guidelines/SKILL.md`）。
它保有防止 `AGENTS.md` 在每次瘦身之后再膨胀的知识落位规则。
`bin/fm-brief.sh` 的脚手架没有可靠办法检测某个任务的仓库就是 firstmate 本身，所以 firstmate 亲手把该技能的加载行加进 firstmate 仓库的任务指令。
领取这类指令的船员即使指令早于本说明，也应加载该技能。
监督活跃船员时，把 firstmate 自己的长时间验证或构建命令放到后台，让看护唤醒仍能得到处理。
船员验证遵循已安装 no-mistakes 版本的 SKILL.md 和实时 `axi` 帮助，而不是在 firstmate 文档里复刻门禁机制。
Firstmate 的包装层仍然重要：船员把每个 ask-user 发现路由给 firstmate，由它应用 `ask-user-authority`；船员绝不传 `--yes` 或 `-y`，因为任一标志都会绕过该检查和任何所需的船长升级。
[`docs/configuration.md`](docs/configuration.md#gate-defaults-no-mistakesyaml) 负责受跟踪的 `.no-mistakes.yaml` 门禁默认值。
`firstmate-coding-guidelines` 技能负责"本地 no-mistakes Test 保持意图定向、不配置 `commands.test`"的规则。
按门禁同样的方式验证：需要什么主题就用 `bin/fm-test-run.sh`，而不是串联 `bash tests/a.test.sh && bash tests/b.test.sh`，因为一串脚本路径获得的与 `--changed` 相同的有界并发。
流水线会自行发布该证据，因此绝不把 `.no-mistakes/` 路径手动提交到特性分支；CI 会把它们当作被跟踪的私有船队路径予以拒绝。

推送前检查并测试工具带：

```sh
while IFS= read -r script; do /bin/bash -n "$script" || exit; done < <(bin/fm-lint.sh --list-files)   # 语法检查 fm-lint.sh 将覆盖的 shell 面（本地为变更文件，CI/main 上为全集）
bin/fm-lint.sh   # lint 该 shell 面外加 GitHub workflows（经固定的 actionlint）；CI 与 no-mistakes 门禁共同运行的唯一所有者
bin/fm-test-run.sh tests/<subject>.test.sh   # 单个脚本（主要的本地聚焦路径，带计时）
bin/fm-test-run.sh tests/<a>.test.sh tests/<b>.test.sh   # 多个主题一次跑：自动有界并发
bin/fm-test-run.sh --family pure-contract-unit   # 常规的家族范围本地路径（串行，带计时）
bin/fm-test-run.sh --changed   # 常规的按变更文件通知路径，自动有界并发
bin/fm-test-run.sh --changed --jobs 1   # 显式串行覆盖
bin/fm-test-run.sh --changed --max-wall-ms 300000   # 同一自动路径，外加运行后五分钟的结果复查
bin/fm-test-run.sh --proven-isolated --jobs 4   # 对逐一证明过的集合做显式本地并行
bin/fm-test-run.sh --lane portable-serial   # 可移植串行余量（watcher/AFK/tmux/有状态）
bin/fm-test-run.sh --list-lanes   # 发现确切泳道名，包括当前 CI 串行分片
bin/fm-test-run.sh --check-coverage   # 证明可移植分片 + 串行 + 串行分片 + Herdr 等于完整清单
bin/fm-test-run.sh --all   # 有意的完整回归（可选的本地全量走查；不是 no-mistakes Test）
bin/fm-test-isolation-proof.sh --list   # 已证明的可移植并行候选集
bin/fm-test-isolation-proof.sh --jobs 4 --json /tmp/fm-isolation-proof.json   # 重跑可移植候选证明
bin/fm-test-isolation-proof.sh --pool watcher-wake-lock --jobs 4   # 重跑某个已准入的家族证明
[ ! -L CLAUDE.md ] && cmp -s CLAUDE.md - <<'EOF'
<!-- Points Claude at AGENTS.md via import; edit AGENTS.md, not this file. -->
@AGENTS.md
EOF
[ "$(readlink .claude/skills)" = "../.agents/skills" ]
tmp=$(mktemp -d) && printf 'done: smoke\n' > "$tmp/smoke.status" && FM_STATE_OVERRIDE="$tmp" FM_SIGNAL_GRACE=1 FM_POLL=1 FM_HEARTBEAT=999999 bin/fm-watch-arm.sh  # 看护重臂冒烟测试（打印布防状态，然后一条可操作的信号）
```

`bin/fm-test-run.sh` 是行为套件选择、可移植 CI 泳道组成、有界并发准入、每脚本计时标记、家族总计、覆盖守卫和可选 JSON 计时工件的唯一所有者。
其头注释和 `--help` 负责标志、家族标签、泳道和变更文件映射；本节只记录入口。
`bin/fm-test-isolation-proof.sh` 仍是可移植候选证明和可复用家族证明装置的唯一所有者；见 `docs/fm-test-isolation-proof.md`。
可移植分片均衡证据在 `docs/fm-test-portable-shards.md`。
家族选择是普通的本地路径；`--all` 仅用于有意的完整回归。
CI 在 [`.github/workflows/ci.yml`](.github/workflows/ci.yml) 中负责跨必需的可移植并行分片、可移植串行泳道的独立 runner 分片、Herdr 泳道、lint、不变量、覆盖守卫以及 stock macOS Bash 兼容性的广泛回归。
向某个 pull request 推送新 head 会取消该 PR 仍在运行的 CI，因此只有当前 head 被验证；推到 `main` 的推送永不取消，workflow 负责该契约及其理由。
在本地复现某条泳道时，用 `bin/fm-test-run.sh --list-lanes` 获取确切泳道名，用 `--help` 了解 `--jobs` 规则和所需的门禁跳过标志。
不要动各套件有界条件等待里的 `sleep 0.1` 节奏。
这些 sleep 看似可回收的开销 - 仅 `fm-watch-triage.test.sh` 就发出约 1,900 次，每次在 macOS 上支付约 100ms 的固定调度唤醒罚金 - 但它们不是加到时钟上的开销；它们是一个测试等待某个只在 `fm-watch.sh` 自己的一秒 `FM_POLL` 节奏上移动的主体时的方式。
降低采样频率并不能消除那个等待，只会推迟发现：2026-09-03 的背靠背测量显示，把间隔提高到 0.5s 并按比例给每个样本计费，`fm-watch-triage.test.sh` 耗时 435s 和 440s，而未改动的脚本为 390s 和 393s，因为它约 40 个轮询周期等待和约 73 个进程退出等待每个最多多付半秒。
其中一些循环还在捕捉瞬态而非等待已稳定的条件，因此更粗的采样可能恰好迈过它们所断言的状态。
通过列出 `tests/*.test.sh` 来发现测试：每个都是名为 `<subject>.test.sh` 的自包含 bash 脚本，其头注释描述覆盖范围；把一个传给 `bin/fm-test-run.sh`，即可用规范的计时输出聚焦某个主题。
共享测试辅助位于 `tests/lib.sh`（报告器、临时根、git 夹具）、`tests/fixtures.sh`（假工具链和 spawn 世界构建器）、`tests/wake-helpers.sh`、`tests/secondmate-helpers.sh` 和 `tests/git-config-helpers.sh`（把夹具 Git 与主机的全局和系统配置隔离，已被 `tests/lib.sh` 和 `tests/herdr-test-safety.sh` source；两者都不 source 的套件必须在第一个 Git 操作前自行 source，保证直接调用时仍是隔离的）。
请 source 它们，而不是把假工具链复制进新套件。
夹具可以把生产超时缩短以让失败路径及时出现，但绝不能低于该窗口内真实工作在负载机器上的成本：一次 fork、一次 exec、一次锁获取、一次信标发布或一次首轮轮询检查。
当用例的断言与超时本身无关时，给那个窗口留出高于实测负载成本的余量，并用按迭代计数的轮询循环约束测试自身的等待，它会在负载下自然拉长，而墙时钟预算不会。
需要真实可选后端或显式选择加入的测试（真实 herdr/zellij/cmux 冒烟测试、live Pi 回归）会自行跳过，并打印启用所需的工具或环境门，因此可移植套件在没有这些工具的机器上仍然安全。
[Herdr 后端指南](docs/herdr-backend.md#destructive-lab-safety)负责该泳道的隔离边界，[运行后端验证](docs/verification/runtime-backends.md#herdr)负责活跃实证证据；live harness 凭证测试保持选择加入。

## 提问

开一个 issue，或在 [Discord](https://discord.gg/Wsy2NpnZDu) 上找我聊。

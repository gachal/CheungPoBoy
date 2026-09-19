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
> firstmate 的完整介绍、架构、配置与使用说明以上游仓库为准，本 README 不再复述。
> 本 fork 保留的本地操作文档：[配置](docs/configuration.md)、[tmux](docs/tmux-backend.md)、[Herdr](docs/herdr-backend.md)、[Zellij](docs/zellij-backend.md)、[Orca](docs/orca-backend.md)、[cmux](docs/cmux-backend.md)、[远程二副](docs/remote-secondmates.md)、[卡滞告警](docs/wedge-alarm.md)、[文档读者分类](docs/documentation-audiences.md)。

## 本 fork 的代理支持

本 fork 只支持以下四种代理，`bin/fm-spawn.sh` 会在两条选择路径上拒绝其余所有适配器名：

- **Codex** - 沿用上游已实机验证的适配，是本 fork 唯一可运行二副（secondmate）的代理。
- **ZCode** - ZCode 桌面应用实际自带 CLI（macOS 上位于 `/Applications/ZCode.app/Contents/Resources/glm/zcode.cjs`，默认不装进 PATH），firstmate 会先找 PATH 再解析捆绑路径；会话检测（`ZCODE_*` 环境标记与 `zcode-cli`/`zcode-host-*`/`ZCode` 进程名）已于 2026-09-17 在真实 ZCode 3.12.3 会话中实测。面板级行为（自动提交、忙碌状态、中断/退出）验证待做。
- **Qoder** - 已按其 CLI 帮助面完成适配（位置参数初始提示、`--dangerously-skip-permissions`、`--model`、`--reasoning-effort`），面板级行为验证待做。
- **CodeBuddy** - 已按其 CLI 帮助面完成适配（位置参数初始提示、`-y`、`--model`），注意其帮助文本声明 HIGH/CRITICAL 权限仍会询问；面板级行为验证待做。

ZCode、Qoder、CodeBuddy 三者均为船员/侦察（crewmate/scout）适配器，暂不能作为二副运行（尚无主代理监督协议）。

## 许可证

MIT - 见 [LICENSE](LICENSE)。

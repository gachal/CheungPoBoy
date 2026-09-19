# CodeBuddy Code CLI

Tencent's `codebuddy` CLI (alias `cbc`), Claude-Code-shaped, adapted on 2026-09-17 from the verified `codebuddy --help` surface on the installed CLI.
Adapted, not live-verified: no pane-level behavior below marked unverified has been observed end to end, so treat every such fact as a blocker to escalate under `../../../../../AGENTS.md` section 9, not an assumption to act on.
Crewmate and scout adapter only; `../../../../../bin/fm-spawn.sh` refuses a secondmate launch on it because `../../../../../docs/supervision-protocols/` carries no codebuddy wake protocol.

## Operating facts

| Fact | Value |
|---|---|
| Binary | `codebuddy` from `PATH`. |
| Launch | `codebuddy -y --model <id> "<brief>"` - a positional prompt starts the interactive session, the claude shape (help surface verified; interactive auto-submit UNVERIFIED). |
| Autonomy | `-y/--dangerously-skip-permissions` bypasses permission prompts, but HIGH/CRITICAL prompts still ask per its own help text, so an unattended crew can park on a high-risk approval; treat a parked HIGH/CRITICAL prompt as a captain decision rather than typing into the pane. |
| Busy state | No per-harness busy source; nothing is armed and no record is seeded. Pane busy classification is UNVERIFIED, so supervision relies on the worker status protocol. The CLI's hook infrastructure (its debug categories name hooks) is a candidate for a future verified turn-end integration. |
| Turn end | No turn-end hook verified; completion arrives through the worker status protocol. |
| Exit / Interrupt | UNVERIFIED; no pane-level key contract has been observed. Drive lifecycle through `../../../../../bin/fm-control.sh` and observe the pane before acting. |
| Skill | No verified slash-skill form; use natural language. |
| Marker | None known; codebuddy publishes no verified identity marker, and the launch clears inherited foreign markers because codebuddy has no verified ancestry signature of its own yet. |
| Worktree | `-w/--worktree [name]` and `--worktree-branch` exist; firstmate passes neither because the pane already starts in the task worktree and `--worktree` would allocate a second one. |
| Resume | `-c/--continue` and `-r/--resume <sessionId>` exist; no verified pane-resume contract, so use deterministic relaunch. |
| Model | `--model <model id>`; the help enumerates the supported id family. Spawn does not validate the id against a live listing yet. |
| Effort | No reasoning-effort flag exists in the help surface, so the effort axis stays in task metadata under the record-and-omit contract. |

## What live verification still owes

A supervised trial task on a real pane must confirm: the positional brief auto-submits, `-y` leaves no routine approval gate (and which operations still park on HIGH/CRITICAL), no first-run or trust dialog parks the worker, busy and idle tails, the interrupt and exit key contracts, and steering delivery.
Until then, this adapter's spawn reports success only on launch, and every pane-level supervision fact above stays marked unverified.

## Primary integration

Unsupported and unverified.
`../../../../../docs/supervision-protocols/` carries no codebuddy protocol, and no turn-end guard adapter exists.
`references/common/primary-hooks.md`'s unsupported-boundary rule applies: never invent a wake protocol from a similar TUI.

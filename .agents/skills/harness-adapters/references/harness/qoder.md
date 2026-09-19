# Qoder CLI

Qoder's `qoder` CLI (usage banner `qodercli`), adapted on 2026-09-17 from the verified `qoder --help` surface on the installed CLI at `~/.qoder/entry/qoder`.
Adapted, not live-verified: no pane-level behavior below marked unverified has been observed end to end, so treat every such fact as a blocker to escalate under `../../../../../AGENTS.md` section 9, not an assumption to act on.
Crewmate and scout adapter only; `../../../../../bin/fm-spawn.sh` refuses a secondmate launch on it because `../../../../../docs/supervision-protocols/` carries no qoder wake protocol.

## Operating facts

| Fact | Value |
|---|---|
| Binary | `qoder` from `PATH` (installed by Qoder under `~/.qoder/entry`); refused implicitly by the pane if absent. |
| Launch | `qoder --dangerously-skip-permissions --model <id> --reasoning-effort <level> "<brief>"` - a positional query is the initial prompt of the interactive session, the claude shape (help surface verified; interactive auto-submit UNVERIFIED). `-i/--prompt-interactive <text>` documents the same execute-and-continue shape explicitly. |
| Busy state | No per-harness busy source; nothing is armed and no record is seeded. Pane busy classification is UNVERIFIED, so supervision relies on the worker status protocol. |
| Turn end | No turn-end hook verified; completion arrives through the worker status protocol. |
| Exit / Interrupt | UNVERIFIED; no pane-level key contract has been observed. Drive lifecycle through `../../../../../bin/fm-control.sh` and observe the pane before acting. |
| Skill | No verified slash-skill form; use natural language. |
| Marker | None known; qoder publishes no verified identity marker, and the launch clears inherited foreign markers because qoder has no verified ancestry signature of its own yet. |
| Worktree | `-w/--cwd <dir>` and `--worktree [name]` exist; firstmate passes neither because the pane already starts in the task worktree and `--worktree` would allocate a second one. `--config-dir <dir>` offers an isolated config root if a future verified launch needs one. |
| Resume | `-c/--continue`, `-r/--resume [id]`, and `--fork-session` exist; no verified pane-resume contract, so use deterministic relaunch. |
| Model | `-m/--model <model>`, where New Models take a model name and Custom takes a modelID; `--list-models` enumerates the account's models. Spawn does not validate the id against the listing yet. |
| Effort | `--reasoning-effort <level>`; the help does not enumerate accepted levels, so only `low`, `medium`, and `high` are passed and higher efforts stay in task metadata under the record-and-omit contract. `--thinking` modes and `--thinking-budget` exist but are not mapped. |

## What live verification still owes

A supervised trial task on a real pane must confirm: the positional brief auto-submits, `--dangerously-skip-permissions` leaves no approval gate, no first-run or trust dialog parks the worker, busy and idle tails, the interrupt and exit key contracts, and steering delivery.
Until then, this adapter's spawn reports success only on launch, and every pane-level supervision fact above stays marked unverified.

## Primary integration

Unsupported and unverified.
`../../../../../docs/supervision-protocols/` carries no qoder protocol, and no turn-end guard adapter exists.
`references/common/primary-hooks.md`'s unsupported-boundary rule applies: never invent a wake protocol from a similar TUI.

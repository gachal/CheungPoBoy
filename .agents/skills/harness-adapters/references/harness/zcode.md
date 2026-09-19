# ZCode CLI

ZCode's bundled CLI, adapted on 2026-09-17 from the verified `zcode --help` surface (zcode 0.16.5, bundled with the ZCode 3.12.3 desktop app) plus live detection evidence gathered inside a real ZCode session.
Adapted, not live-verified: no pane-level behavior below marked unverified has been observed end to end, so treat every such fact as a blocker to escalate under `../../../../../AGENTS.md` section 9, not an assumption to act on.
Crewmate and scout adapter only; `../../../../../bin/fm-spawn.sh` refuses a secondmate launch on it because `../../../../../docs/supervision-protocols/` carries no zcode wake protocol.

## Operating facts

| Fact | Value |
|---|---|
| Binary | `zcode` from `PATH` when present, else the executable bundled at `/Applications/ZCode.app/Contents/Resources/glm/zcode.cjs` (a node script with a shebang and the executable bit); the spawn refuses when neither exists. ZCode installs no PATH binary by default (verified 2026-09-17, ZCode 3.12.3). |
| Launch | `zcode "<brief>"` - a positional prompt opens the TUI session, the claude shape (help surface verified; interactive auto-submit UNVERIFIED). `--mode` defaults to `yolo` for prompts, so no permission flag is passed. |
| Headless | `--prompt <text>` runs a single prompt without the TUI and `-p/--print` runs a positional prompt headlessly; firstmate does not use these for crewmates. |
| Busy state | No per-harness busy source; nothing is armed and no record is seeded. Pane busy classification is UNVERIFIED, so supervision relies on the worker status protocol. |
| Turn end | No turn-end hook or notify surface verified; completion arrives through the worker status protocol. |
| Exit / Interrupt | UNVERIFIED; no pane-level key contract has been observed. Drive lifecycle through `../../../../../bin/fm-control.sh` and observe the pane before acting. |
| Skill | No verified slash-skill form; use natural language. |
| Marker | The `ZCODE_*` environment family (at least `ZCODE_APP_VERSION`, `ZCODE_BASE_URL`, `ZCODE_ENV`, `ZCODE_PROCESS_LABEL`) reaches tool subprocesses - verified live inside a real ZCode 3.12.3 desktop session on 2026-09-17. |
| Ancestry | Live desktop sessions run `zcode-cli` under `zcode-host-local-1` under the `ZCode` app process (verified live, 3.12.3); `../../../../../bin/fm-harness.sh` also matches `zcode.cjs` in an interpreter's arguments for bundled-CLI launches, whose own process naming is UNVERIFIED. |
| Resume | `--resume <sessionId>` and `-c/--continue` exist; no verified pane-resume contract, so use deterministic relaunch. |
| Model / Effort | The CLI exposes no `--model` and no reasoning-effort flag (0.16.5), so both axes stay in task metadata under the record-and-omit contract. |
| Credential | `login`/`logout` manage the shared Z.AI login, so a signed-in desktop app is expected to authenticate the CLI too; that sharing is inferred from the help wording and UNVERIFIED. Treat any auth prompt as a credential blocker rather than typing into it. |

## What live verification still owes

A supervised trial task on a real pane must confirm: the positional brief auto-submits in the TUI, no first-run or trust dialog parks the worker, busy and idle tails, the interrupt and exit key contracts, and steering delivery.
Until then, this adapter's spawn reports success only on launch, and every pane-level supervision fact above stays marked unverified.

## Primary integration

Unsupported and unverified.
`../../../../../docs/supervision-protocols/` carries no zcode protocol, so a zcode primary renders the unknown-harness fallback protocol, and no turn-end guard adapter exists.
`references/common/primary-hooks.md`'s unsupported-boundary rule applies: never invent a wake protocol from a similar TUI.

#!/usr/bin/env bash
# Behavior tests for this fork's supported-harness gate in bin/fm-spawn.sh.
#
# The fork dispatches only on codex, zcode, qoder, and codebuddy, and the gate
# must refuse every other adapter name at BOTH selection paths (explicit
# argument and config resolution) before any endpoint, worktree, or task record
# exists, while the raw-launch escape hatch stays outside the gate entirely.
# Every case here fails fast at the gate, the harness resolution, or the
# project-dir resolution, all of which precede any tmux/treehouse side effect,
# so these tests create no windows or worktrees.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SPAWN="$ROOT/bin/fm-spawn.sh"
TMP_ROOT=$(fm_test_tmproot fm-fork-harness-gate)
export FM_BACKEND=tmux

# Clear ambient firstmate overrides so the behavior test owns its environment.
run_spawn() {
  FM_ROOT_OVERRIDE='' \
    FM_HOME='' \
    FM_STATE_OVERRIDE='' \
    FM_DATA_OVERRIDE='' \
    FM_PROJECTS_OVERRIDE='' \
    FM_CONFIG_OVERRIDE='' \
    FM_SPAWN_NO_GUARD=1 \
    "$SPAWN" "$@" 2>&1
}

# Same, but scoped to a fixture home whose config dir the caller prepared.
run_home_spawn() {  # <home> [args...]
  local home=$1
  shift
  FM_ROOT_OVERRIDE='' \
    FM_HOME="$home" \
    FM_STATE_OVERRIDE="$home/state" \
    FM_DATA_OVERRIDE="$home/data" \
    FM_PROJECTS_OVERRIDE="$home/projects" \
    FM_CONFIG_OVERRIDE="$home/config" \
    FM_SPAWN_NO_GUARD=1 \
    "$SPAWN" "$@" 2>&1
}

FORK_SET_LINE='supported: codex, zcode, qoder, codebuddy'

test_explicit_retired_harness_refused() {
  local name out status
  for name in claude opencode pi pi-signed grok kimi cursor gemini muse rovo omp agy; do
    out=$(run_spawn "gate-explicit-$name" projects/none "$name" --mode no-mistakes --yolo off)
    status=$?
    [ "$status" -ne 0 ] || fail "explicit '$name' spawn unexpectedly succeeded"
    printf '%s\n' "$out" | grep -F "harness '$name' is not supported by this fork" >/dev/null \
      || fail "explicit '$name' refusal does not name the harness"
    printf '%s\n' "$out" | grep -F "$FORK_SET_LINE" >/dev/null \
      || fail "explicit '$name' refusal does not name the fork's supported set"
  done
  pass "every retired adapter name is refused on the explicit path and names the fork set"
}

test_config_resolved_retired_harness_refused() {
  local home out status
  home="$TMP_ROOT/home-claude"
  mkdir -p "$home/config" "$home/data" "$home/state" "$home/projects"
  printf 'claude\n' > "$home/config/crew-harness"
  out=$(run_home_spawn "$home" gate-config projects/none --mode no-mistakes --yolo off)
  status=$?
  [ "$status" -ne 0 ] || fail "config-pinned claude spawn unexpectedly succeeded"
  printf '%s\n' "$out" | grep -F "harness 'claude' (from config/crew-harness or detection) is not supported by this fork" >/dev/null \
    || fail "config-path refusal does not name the harness and its config source"
  printf '%s\n' "$out" | grep -F "$FORK_SET_LINE" >/dev/null \
    || fail "config-path refusal does not name the fork's supported set"
  pass "a retired harness pinned in config/crew-harness is refused with its config source named"
}

test_fork_harnesses_pass_the_gate() {
  local name out status fakebin
  # A PATH zcode makes zcode binary resolution deterministic on hosts without
  # the ZCode desktop app bundle.
  fakebin="$TMP_ROOT/fakebin"
  mkdir -p "$fakebin"
  printf '#!/bin/sh\nexit 0\n' > "$fakebin/zcode"
  chmod +x "$fakebin/zcode"
  for name in codex zcode qoder codebuddy; do
    out=$(PATH="$fakebin:$PATH" run_spawn "gate-pass-$name" projects/none "$name" --mode no-mistakes --yolo off)
    status=$?
    [ "$status" -ne 0 ] || fail "'$name' spawn unexpectedly succeeded against a missing project"
    case "$out" in
      *"not supported by this fork"*) fail "'$name' hit the fork gate; it belongs to the supported set" ;;
      *"no launch template"*) fail "'$name' has no launch template behind the fork gate" ;;
      *"zcode executable not found"*) fail "zcode PATH binary was not resolved" ;;
    esac
  done
  pass "all four fork harnesses clear the gate and resolve a launch template"
}

test_secondmate_refused_for_new_adapters() {
  local name home out status
  home="$TMP_ROOT/sm-home"
  mkdir -p "$home/config" "$home/data" "$home/state" "$home/projects"
  for name in zcode qoder codebuddy; do
    out=$(run_home_spawn "$home" "gate-sm-$name" "$home" "$name" --secondmate)
    status=$?
    [ "$status" -ne 0 ] || fail "$name secondmate spawn unexpectedly succeeded"
    printf '%s\n' "$out" | grep -F "$name is a crewmate/scout adapter only and cannot run a secondmate" >/dev/null \
      || fail "$name secondmate refusal does not state the crewmate-only boundary"
  done
  pass "zcode, qoder, and codebuddy are refused as secondmates with the boundary named"
}

test_raw_launch_escape_hatch_not_gated() {
  local out status
  out=$(run_spawn gate-raw projects/none 'mycustom-agent --flag' --mode no-mistakes --yolo off)
  status=$?
  [ "$status" -ne 0 ] || fail "raw launch against a missing project unexpectedly succeeded"
  case "$out" in
    *"not supported by this fork"*) fail "the raw-launch escape hatch was swallowed by the fork gate" ;;
  esac
  pass "the raw-launch escape hatch stays outside the fork gate"
}

test_explicit_retired_harness_refused
test_config_resolved_retired_harness_refused
test_fork_harnesses_pass_the_gate
test_secondmate_refused_for_new_adapters
test_raw_launch_escape_hatch_not_gated

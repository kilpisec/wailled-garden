#!/usr/bin/env bash
set -euo pipefail

engine="${AGENT_ENGINE:-podman}"
image="${AGENT_IMAGE:-agent-base-image}"
config_volume="${AGENT_CONFIG_VOLUME:-agents}"
worktree_base="${AGENT_WORKTREE_BASE:-$HOME/.agent-worktrees}"
disable_worktree="${AGENT_NO_WORKTREE:-}"

run_args=()
cmd_args=()
seen_sep=false

for arg in "$@"; do
  if [ "$arg" = "--" ]; then
    seen_sep=true
    continue
  fi
  if [ "$seen_sep" = true ]; then
    cmd_args+=("$arg")
  else
    run_args+=("$arg")
  fi
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
mount_dir="$(pwd)"
project_name="$(basename "$mount_dir")"
base_branch=""
worktree_name=""
git_file=""
gitdir_file=""

cleanup() {
  [ -n "$git_file" ] && rm -f "$git_file"
  [ -n "$gitdir_file" ] && rm -f "$gitdir_file"
}
trap cleanup EXIT

if [ -n "$repo_root" ] && [ -z "$disable_worktree" ]; then
  project_name="$(basename "$repo_root")"

  # Prompt for worktree name (allows multiple sessions per project)
  default_worktree="$project_name-agent-worktree"
  if [ -t 0 ]; then
    read -r -p "Worktree name [$default_worktree]: " worktree_input
    project_name="${worktree_input:-$default_worktree}"
  else
    project_name="$default_worktree"
  fi

  mount_dir="$worktree_base/$project_name"
  branch="agent/$project_name"
  base_branch="$(git -C "$repo_root" symbolic-ref -q --short HEAD 2>/dev/null || true)"

  if [ -d "$mount_dir" ]; then
    if ! git -C "$repo_root" worktree list --porcelain | grep -Fq "worktree $mount_dir"; then
      echo "error: $mount_dir exists but is not a git worktree for $repo_root" >&2
      exit 1
    fi
  else
    mkdir -p "$worktree_base"
    if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
      git -C "$repo_root" worktree add "$mount_dir" "$branch"
    else
      git -C "$repo_root" worktree add -b "$branch" "$mount_dir"
    fi
  fi

  # Set up git mounts for container - the worktree's .git file points to host paths
  # so we need to mount the main .git dir and provide a corrected .git file
  worktree_name="$(basename "$mount_dir")"
  git_file="$(mktemp)"
  echo "gitdir: /repo-git/worktrees/$worktree_name" > "$git_file"
  run_args+=(-v "$repo_root/.git:/repo-git")
  run_args+=(-v "$git_file:/workspace/$project_name/.git:ro")

  # Also fix the gitdir file that points back to the worktree
  gitdir_file="$(mktemp)"
  echo "/workspace/$project_name/.git" > "$gitdir_file"
  run_args+=(-v "$gitdir_file:/repo-git/worktrees/$worktree_name/gitdir:ro")
fi

container_name="$(printf '%s' "$project_name" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_.-' '-')"

"$engine" run -it --rm \
  -v "$config_volume:/aconf" \
  --name "$container_name" \
  -v "$mount_dir:/workspace/$project_name" \
  ${run_args[@]+"${run_args[@]}"} \
  -e "PROJECT_NAME=$project_name" \
  "$image" \
  ${cmd_args[@]+"${cmd_args[@]}"}
status=$?

if [ -n "$repo_root" ] && [ -z "$disable_worktree" ]; then
  if [ -e "$mount_dir/.git" ]; then
    if [ -n "$(git -C "$mount_dir" status --porcelain)" ]; then
      echo "notice: uncommitted changes remain in $mount_dir" >&2
    else
      echo "notice: no changes detected in $mount_dir; you can remove it with:" >&2
      echo "  git -C \"$repo_root\" worktree remove \"$mount_dir\"" >&2
    fi

    worktree_branch="$(git -C "$mount_dir" symbolic-ref -q --short HEAD 2>/dev/null || true)"
    if [ -n "$base_branch" ] && [ -n "$worktree_branch" ]; then
      ahead_count="$(git -C "$repo_root" rev-list --count "$base_branch..$worktree_branch" 2>/dev/null || true)"
      if [ -n "$ahead_count" ] && [ "$ahead_count" -gt 0 ]; then
        echo "notice: $worktree_branch has $ahead_count commit(s) not in $base_branch" >&2
      fi
    fi
  fi
fi

exit "$status"

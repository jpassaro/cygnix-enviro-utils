#!/usr/bin/env bash
# Backup local agent and desk state to a destination directory.
# Usage: backup-local-state.sh <destination-dir>
#
# Creates a single timestamped tarball containing:
#   - Agent config (~/.claude, ~/.gemini, etc.)
#   - ~/desk
#   - ~/.config (excluding oauth token caches)
#   - Non-git directories under ~/code (depth 1-3), unless excluded by
#     a .jp-backup-exclude marker in the directory or an ancestor
#
# Also writes a git snapshot of every repo/worktree under ~/code/ to
# ~/.config/jp-agent/code-snapshot/ before archiving.
#
# Paths inside the archive are relative to $HOME.
#
# The destination is intentionally not hardcoded — it varies by environment
# (OneDrive, S3, a mounted volume, etc.). The caller supplies it.

set -e

dest="${1:?Usage: backup-local-state.sh <destination-dir>}"

if [[ ! -d "$dest" ]]; then
    printf 'error: destination directory does not exist: %s\n' "$dest" >&2
    exit 1
fi

stamp="$(date '+%Y%m%d-%H%M')"
archive="${dest}/local-state-${stamp}.tar.gz"

# --- Git snapshot -----------------------------------------------------------
snapshot_dir="$HOME/.config/jp-agent/code-snapshot"

find "$HOME/code" -maxdepth 3 -name .git -print0 | while IFS= read -r -d '' gitdir; do
    repo_dir="$(dirname "$gitdir")"
    rel="${repo_dir#"$HOME"/code/}"
    outdir="$snapshot_dir/$rel"
    mkdir -p "$outdir"

    # Remove stale bundles from previous runs
    find "$outdir" -name '*.bundle' -delete 2>/dev/null

    # Fetch and update origin/HEAD (unless .jp-no-fetch)
    if [[ ! -e "$repo_dir/.jp-no-fetch" ]]; then
        if (cd "$repo_dir" && git fetch origin 2>/dev/null); then
            (cd "$repo_dir" && git remote set-head origin -a 2>/dev/null) || true
        else
            printf 'WARNING: fetch failed for %s\n' "$rel" >&2
        fi
    fi

    # Print FETCH_HEAD mtime
    fetch_head="$repo_dir/.git/FETCH_HEAD"
    [[ -f "$repo_dir/.git" ]] && fetch_head="$(cd "$repo_dir" && git rev-parse --git-dir)/FETCH_HEAD"

    {
        printf '=== %s ===\n' "$rel"
        (cd "$repo_dir" && set -x && git remote -v && git worktree list) 2>&1
        if [[ -e "$fetch_head" ]]; then
            printf 'FETCH_HEAD mtime: %s\n' "$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$fetch_head" 2>/dev/null || stat -c '%y' "$fetch_head" 2>/dev/null | cut -d. -f1)"
        else
            printf 'FETCH_HEAD: (none)\n'
        fi
        echo ""

        (cd "$repo_dir" && git worktree list --porcelain) 2>/dev/null \
        | grep '^worktree ' | sed 's/^worktree //' \
        | while IFS= read -r wt; do
            printf -- '--- %s ---\n' "$wt"
            (cd "$wt" && set -x +e && { git status -u; git rev-parse HEAD '@{upstream}'; }) 2>&1 || true
            base=""
            if (cd "$wt" && git rev-parse '@{upstream}' >/dev/null 2>&1); then
                base='@{upstream}'
            else
                for candidate in refs/remotes/origin/HEAD refs/remotes/origin/main refs/remotes/origin/master refs/heads/main refs/heads/master; do
                    if (cd "$wt" && git rev-parse "$candidate" >/dev/null 2>&1); then
                        base="$candidate"
                        break
                    fi
                done
            fi
            if [[ -n "$base" ]]; then
                (cd "$wt" && set -x && git log --oneline "${base}..HEAD") 2>&1
                if [[ ! -e "$wt/.jp-no-bundle" ]]; then
                    commit_count="$(cd "$wt" && git rev-list --count "${base}..HEAD" 2>/dev/null || echo 0)"
                    if (( commit_count > 0 )); then
                        bundle_name="$(basename "$wt").bundle"
                        if (cd "$wt" && git bundle create "$outdir/$bundle_name" "${base}..HEAD" 2>/dev/null); then
                            printf 'Bundled %d unpushed commit(s): %s\n' "$commit_count" "$outdir/$bundle_name" >&2
                        else
                            printf 'WARNING: failed to bundle %s\n' "$wt" >&2
                        fi
                    fi
                fi
            fi
            if (cd "$wt" && ! git diff --quiet 2>/dev/null) || (cd "$wt" && ! git diff --cached --quiet 2>/dev/null); then
                printf 'WARNING: dirty working tree not captured in bundle: %s\n' "$wt" >&2
            fi
            if [[ -n "$(cd "$wt" && git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
                printf 'WARNING: untracked files not captured in bundle: %s\n' "$wt" >&2
            fi
            echo ""
        done
    } > "$outdir/status.txt"
done

printf 'Git snapshot written to %s\n' "$snapshot_dir"

# --- Non-git dirs from ~/code (depth 1-3) ----------------------------------
has_backup_exclude() {
    local d="$1"
    while [[ "$d" != "$HOME/code" && "$d" != "/" ]]; do
        if [[ -e "$d/.jp-backup-exclude" ]]; then
            return 0
        fi
        d="$(dirname "$d")"
    done
    return 1
}

is_inside_git() {
    local d="$1"
    while [[ "$d" != "$HOME/code" && "$d" != "/" ]]; do
        if [[ -e "$d/.git" ]]; then
            return 0
        fi
        d="$(dirname "$d")"
    done
    return 1
}

code_targets=()
while IFS= read -r -d '' d; do
    [[ -d "$d" ]] || continue
    is_inside_git "$d" && continue
    has_backup_exclude "$d" && continue
    code_targets+=("${d#"$HOME"/}")
done < <(find "$HOME/code" -mindepth 1 -maxdepth 3 -type d -print0)

if (( ${#code_targets[@]} > 0 )); then
    printf 'Including %d non-git dirs from ~/code\n' "${#code_targets[@]}"
fi

# --- Assemble targets -------------------------------------------------------
declare -a targets=(desk)
for item in .claude .gemini .ssh/config .vimrc .gitconfig .config; do
    if [[ -e "$HOME/$item" ]]; then
        targets+=("$item")
    fi
done
targets+=("${code_targets[@]}")

tar -czf "$archive" -C "$HOME" \
    --exclude='oauth' \
    --exclude='target' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='venv' \
    --exclude='.metals' \
    --exclude='.bloop' \
    --exclude='.bsp' \
    --exclude='__pycache__' \
    "${targets[@]}"

printf 'Backed up to %s\n' "$archive"

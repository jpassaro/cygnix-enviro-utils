#!/usr/bin/env bash
# Backup local agent and desk state to a destination directory.
# Usage: backup-local-state.sh <destination-dir>
#
# Creates a single timestamped tarball containing agent config (e.g. ~/.claude, ~/.gemini) and ~/desk.
# Paths inside the archive are relative to $HOME (e.g., .claude/settings.json).
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

declare -a targets=(desk)
for dir in .claude .gemini; do
    if [[ -d "$HOME/$dir" ]]; then
        targets+=("$dir")
    fi
done

tar -czf "$archive" -C "$HOME" "${targets[@]}"

printf 'Backed up to %s\n' "$archive"

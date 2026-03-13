#!/bin/sh
# Backup local Claude and desk state to a destination directory.
# Usage: backup-local-state.sh <destination-dir>
#
# Creates a single timestamped tarball containing ~/.claude and ~/desk.
# Paths inside the archive are relative to $HOME (e.g., .claude/settings.json).
#
# The destination is intentionally not hardcoded — it varies by environment
# (OneDrive, S3, a mounted volume, etc.). The caller supplies it.

set -e

dest="${1:?Usage: backup-local-state.sh <destination-dir>}"

if [ ! -d "$dest" ]; then
    printf 'error: destination directory does not exist: %s\n' "$dest" >&2
    exit 1
fi

stamp="$(date '+%Y%m%d-%H%M')"
archive="${dest}/local-state-${stamp}.tar.gz"

tar -czf "$archive" -C "$HOME" .claude desk

printf 'Backed up to %s\n' "$archive"

#!/bin/bash
# Syncs global Claude standards into the current project's .claude/standards/.
# SAFE: never touches the project's root CLAUDE.md or any other project files.
# Idempotent — safe to run repeatedly.

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/standards/"
TARGET_DIR="./.claude/standards/"

mkdir -p "$TARGET_DIR"
rsync -au --delete "$SOURCE_DIR" "$TARGET_DIR"

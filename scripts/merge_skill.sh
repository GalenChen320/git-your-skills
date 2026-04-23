#!/bin/bash

# ============================================================
# merge_skill.sh
# Usage: ./merge_skill.sh <skill_name> <source> <target>
# Merges source branch INTO target branch.
# ============================================================

set -e

SKILL_NAME=$1
SOURCE=$2
TARGET=$3
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ] || [ -z "$SOURCE" ] || [ -z "$TARGET" ]; then
  echo "❌ Error: skill_name, source, and target are all required."
  echo "   Usage: ./merge_skill.sh <skill_name> <source> <target>"
  echo "   Example: ./merge_skill.sh my-skill main-20260422153000 main"
  exit 1
fi

# ────────────────────────────────────────
# 2. 检查 git 是否安装
# ────────────────────────────────────────
if ! command -v git &> /dev/null; then
  echo "❌ Error: git is not installed."
  echo "   Please install git and try again."
  exit 1
fi

# ────────────────────────────────────────
# 3. 检查 skill 目录是否存在
# ────────────────────────────────────────
if [ ! -d "$SKILL_PATH" ]; then
  echo "❌ Error: skill directory does not exist."
  echo "   Path: $SKILL_PATH"
  exit 1
fi

# ────────────────────────────────────────
# 4. 检查 git 是否已初始化
# ────────────────────────────────────────
if [ ! -d "$SKILL_PATH/.git" ]; then
  echo "❌ Error: git is not initialized for skill '$SKILL_NAME'."
  echo "   Please run initialize_skill first."
  exit 1
fi

# ────────────────────────────────────────
# 5. 检查 source 和 target 是否有效
# ────────────────────────────────────────
if ! git -C "$SKILL_PATH" rev-parse --verify "$SOURCE" &> /dev/null; then
  echo "❌ Error: invalid source ref '$SOURCE'."
  exit 1
fi

if ! git -C "$SKILL_PATH" rev-parse --verify "$TARGET" &> /dev/null; then
  echo "❌ Error: invalid target ref '$TARGET'."
  exit 1
fi

# ────────────────────────────────────────
# 6. 确保 git user 配置存在（本地）
# ────────────────────────────────────────
if [ -z "$(git -C "$SKILL_PATH" config user.name)" ]; then
  git -C "$SKILL_PATH" config user.name "opencode"
fi
if [ -z "$(git -C "$SKILL_PATH" config user.email)" ]; then
  git -C "$SKILL_PATH" config user.email "opencode@local"
fi

# ────────────────────────────────────────
# 7. Checkout target 并 merge source
# ────────────────────────────────────────
git -C "$SKILL_PATH" checkout "$TARGET"

MERGE_RESULT=$(git -C "$SKILL_PATH" merge "$SOURCE" 2>&1) || true

if echo "$MERGE_RESULT" | grep -q "CONFLICT"; then
  echo ""
  echo "⚠️  Merge conflict detected in the following files:"
  git -C "$SKILL_PATH" diff --name-only --diff-filter=U
  echo ""
  echo "The repository is in a merge state. Please resolve all conflicts, then use update_skill to commit."
  exit 0
fi

if echo "$MERGE_RESULT" | grep -q "Already up to date"; then
  echo "ℹ️  Already up to date. Nothing to merge."
  exit 0
fi

COMMIT_HASH=$(git -C "$SKILL_PATH" rev-parse --short HEAD)

echo ""
echo "✅ Merge completed successfully."
echo "   Skill: $SKILL_NAME"
echo "   Source: $SOURCE → Target: $TARGET"
echo "   Commit: $COMMIT_HASH"

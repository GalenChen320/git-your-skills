#!/bin/bash

# ============================================================
# show_diff.sh
# Usage: ./show_diff.sh <skill_name> <from> <to>
# ============================================================

set -e

SKILL_NAME=$1
FROM=$2
TO=$3
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ] || [ -z "$FROM" ] || [ -z "$TO" ]; then
  echo "❌ Error: skill_name, from, and to are all required."
  echo "   Usage: ./show_diff.sh <skill_name> <from> <to>"
  echo "   Example: ./show_diff.sh my-skill abc1234 def5678"
  echo "   Example: ./show_diff.sh my-skill main main-20260422153000"
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
# 5. 检查 from 和 to 是否有效
# ────────────────────────────────────────
if ! git -C "$SKILL_PATH" rev-parse --verify "$FROM" &> /dev/null; then
  echo "❌ Error: invalid ref '$FROM'."
  exit 1
fi

if ! git -C "$SKILL_PATH" rev-parse --verify "$TO" &> /dev/null; then
  echo "❌ Error: invalid ref '$TO'."
  exit 1
fi

# ────────────────────────────────────────
# 6. 显示 diff
# ────────────────────────────────────────
echo "📄 Diff: $FROM → $TO"
echo ""
git -C "$SKILL_PATH" diff "$FROM" "$TO"

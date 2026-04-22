#!/bin/bash

# ============================================================
# commit_skill.sh
# Usage: ./commit_skill.sh <skill_name> <commit_message>
# ============================================================

set -e

SKILL_NAME=$1
COMMIT_MSG=$2
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ]; then
  echo "❌ Error: skill name is required."
  echo "   Usage: ./commit_skill.sh <skill_name> <commit_message>"
  exit 1
fi

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Error: commit message is required."
  echo "   Usage: ./commit_skill.sh <skill_name> <commit_message>"
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
  echo "   Please run initialize_skill first:"
  echo "   ./initialize_skill.sh $SKILL_NAME"
  exit 1
fi

# ────────────────────────────────────────
# 5. 检查是否有变更
# ────────────────────────────────────────
git -C "$SKILL_PATH" add .

if git -C "$SKILL_PATH" diff --cached --quiet; then
  echo "ℹ️  Nothing to commit. Working tree is clean."
  exit 0
fi

# ────────────────────────────────────────
# 6. 执行 commit
# ────────────────────────────────────────
echo "📝 Committing changes..."

if ! git -C "$SKILL_PATH" commit -m "$COMMIT_MSG"; then
  echo "❌ Error: commit failed."
  echo "   Please check your git configuration (user.name, user.email)."
  exit 1
fi

echo ""
echo "✅ Changes committed successfully."
echo "   Skill: $SKILL_NAME"
echo "   Message: $COMMIT_MSG"

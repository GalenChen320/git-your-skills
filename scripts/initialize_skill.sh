#!/bin/bash

# ============================================================
# initialize_skill.sh
# Usage: ./initialize_skill.sh <skill_name>
# ============================================================

set -e

SKILL_NAME=$1
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ]; then
  echo "❌ Error: skill name is required."
  echo "   Usage: ./initialize_skill.sh <skill_name>"
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
# 3. 检查文件夹是否存在
# ────────────────────────────────────────
if [ ! -d "$SKILL_PATH" ]; then
  echo "❌ Error: skill directory does not exist."
  echo "   Path: $SKILL_PATH"
  exit 1
fi

# ────────────────────────────────────────
# 4. 初始化 git（幂等）
# ────────────────────────────────────────
if [ ! -d "$SKILL_PATH/.git" ]; then
  echo "🔧 Initializing git repository..."
  git -C "$SKILL_PATH" init
else
  echo "ℹ️  Git already initialized in: $SKILL_PATH"
fi

# ────────────────────────────────────────
# 5. 提交所有现有文件（幂等）
# ────────────────────────────────────────
git -C "$SKILL_PATH" add .

if git -C "$SKILL_PATH" diff --cached --quiet; then
  echo "ℹ️  Nothing to commit. Working tree is clean."
else
  echo "📝 Committing existing files..."
  git -C "$SKILL_PATH" commit -m "🎉 Initialize skill: $SKILL_NAME"
fi

echo ""
echo "✅ Skill '$SKILL_NAME' is ready."
echo "   Path: $SKILL_PATH"

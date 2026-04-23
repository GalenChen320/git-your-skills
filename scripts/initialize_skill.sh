#!/bin/bash

# ============================================================
# initialize_skill.sh
# Usage: ./initialize_skill.sh <skill_name> [description]
# ============================================================

set -e

SKILL_NAME=$1
SKILL_DESCRIPTION=${2:-None}
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ]; then
  echo "❌ Error: skill name is required."
  echo "   Usage: ./initialize_skill.sh <skill_name> [description]"
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
# 3. 检查文件夹是否存在，不存在则创建
# ────────────────────────────────────────
DIR_NEWLY_CREATED=false
if [ ! -d "$SKILL_PATH" ]; then
  echo "🔧 Skill directory not found. Creating: $SKILL_PATH"
  mkdir -p "$SKILL_PATH"
  DIR_NEWLY_CREATED=true
fi

# ────────────────────────────────────────
# 3.5 如果是新建目录，创建 SKILL.md
# ────────────────────────────────────────
if [ "$DIR_NEWLY_CREATED" = true ]; then
  echo "📝 Creating SKILL.md with frontmatter..."
  cat > "$SKILL_PATH/SKILL.md" <<EOF
---
name: $SKILL_NAME
description: $SKILL_DESCRIPTION
---
EOF
fi

# ────────────────────────────────────────
# 4. 初始化 git（幂等）
# ────────────────────────────────────────
if [ ! -d "$SKILL_PATH/.git" ]; then
  echo "🔧 Initializing git repository..."
  git -C "$SKILL_PATH" init -b main
  git -C "$SKILL_PATH" config user.name "opencode"
  git -C "$SKILL_PATH" config user.email "opencode@local"
else
  echo "ℹ️  Git already initialized in: $SKILL_PATH"
fi

# ────────────────────────────────────────
# 5. 提交所有现有文件（幂等）
# ────────────────────────────────────────
git -C "$SKILL_PATH" add .

if ! git -C "$SKILL_PATH" diff --cached --quiet 2>/dev/null; then
  echo "📝 Committing existing files..."
  git -C "$SKILL_PATH" commit -m "🎉 Initialize skill: $SKILL_NAME"
else
  echo "ℹ️  Nothing to commit. Working tree is clean."
fi

echo ""
echo "✅ Skill '$SKILL_NAME' is ready."
echo "   Path: $SKILL_PATH"

if [ "$DIR_NEWLY_CREATED" = true ]; then
  echo ""
  echo "⚠️  Skill directory was newly created."
  echo "   Please restart the opencode client for the skill to take effect."
fi

#!/bin/bash

# ============================================================
# rollback_skill.sh
# Usage: ./rollback_skill.sh <skill_name> <ref>
# ============================================================

set -e

SKILL_NAME=$1
REF=$2
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ] || [ -z "$REF" ]; then
  echo "❌ Error: skill_name and ref are both required."
  echo "   Usage: ./rollback_skill.sh <skill_name> <ref>"
  echo "   Example: ./rollback_skill.sh my-skill abc1234"
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
# 5. 检查 ref 是否有效
# ────────────────────────────────────────
if ! git -C "$SKILL_PATH" rev-parse --verify "$REF" &> /dev/null; then
  echo "❌ Error: invalid ref '$REF'."
  exit 1
fi

# ────────────────────────────────────────
# 5.5 检查工作区是否有未提交的修改
# ────────────────────────────────────────
if ! git -C "$SKILL_PATH" diff --quiet 2>/dev/null || ! git -C "$SKILL_PATH" diff --cached --quiet 2>/dev/null; then
  echo "❌ Error: uncommitted changes detected in working directory."
  echo "   Please commit or stash your changes before rolling back."
  echo "   Run update_skill first, then try rollback again."
  exit 1
fi

# ────────────────────────────────────────
# 6. 记录当前 HEAD 用于后续对比
# ────────────────────────────────────────
OLD_HEAD=$(git -C "$SKILL_PATH" rev-parse HEAD)

# ────────────────────────────────────────
# 7. 执行 rollback（checkout 到目标 ref）
# ────────────────────────────────────────
git -C "$SKILL_PATH" checkout "$REF"

NEW_HEAD=$(git -C "$SKILL_PATH" rev-parse HEAD)
NEW_HEAD_SHORT=$(git -C "$SKILL_PATH" rev-parse --short HEAD)

echo ""
echo "⏪ Rolled back to: $NEW_HEAD_SHORT"
echo "   Previous HEAD was: $(git -C "$SKILL_PATH" rev-parse --short $OLD_HEAD)"
echo "   Skill: $SKILL_NAME"
echo ""
echo "ℹ️  HEAD is now detached. The original branch is preserved."
echo "   If you update this skill, a new branch will be created automatically."

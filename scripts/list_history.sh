#!/bin/bash

# ============================================================
# list_skill.sh
# Usage: ./list_skill.sh <skill_name> [limit]
# ============================================================

set -e

SKILL_NAME=$1
LIMIT=${2:-20}
SKILL_PATH=".opencode/skills/$SKILL_NAME"

# ────────────────────────────────────────
# 1. 检查参数
# ────────────────────────────────────────
if [ -z "$SKILL_NAME" ]; then
  echo "❌ Error: skill name is required."
  echo "   Usage: ./list_skill.sh <skill_name> [limit]"
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
# 5. 显示分支拓扑
# ────────────────────────────────────────
echo "📊 Branch topology (recent $LIMIT commits):"
echo ""
git -C "$SKILL_PATH" log --graph --oneline --all --decorate -n "$LIMIT"

# ────────────────────────────────────────
# 6. 按时间顺序列出最近提交
# ────────────────────────────────────────
echo ""
echo "📋 Recent commits (chronological, $LIMIT):"
echo ""
git -C "$SKILL_PATH" log --all --format="%h | %ai | %s%d" -n "$LIMIT"

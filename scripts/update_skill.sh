#!/bin/bash

# ============================================================
# update_skill.sh
# Usage: ./update_skill.sh <skill_name> <commit_message>
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
  echo "   Usage: ./update_skill.sh <skill_name> <commit_message>"
  exit 1
fi

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Error: commit message is required."
  echo "   Usage: ./update_skill.sh <skill_name> <commit_message>"
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
# 5. 确保 git user 配置存在（本地）
# ────────────────────────────────────────
if [ -z "$(git -C "$SKILL_PATH" config user.name)" ]; then
  git -C "$SKILL_PATH" config user.name "opencode"
fi
if [ -z "$(git -C "$SKILL_PATH" config user.email)" ]; then
  git -C "$SKILL_PATH" config user.email "opencode@local"
fi

# ────────────────────────────────────────
# 6. 检查是否有变更
# ────────────────────────────────────────
git -C "$SKILL_PATH" add .

if ! git -C "$SKILL_PATH" diff --cached --quiet 2>/dev/null; then
  # ────────────────────────────────────────
  # 6.5 检测 HEAD 是否在分支顶端，否则创建新分支
  # ────────────────────────────────────────
  CURRENT_BRANCH=$(git -C "$SKILL_PATH" rev-parse --abbrev-ref HEAD)

  if [ "$CURRENT_BRANCH" = "HEAD" ]; then
    # HEAD is detached (e.g., after rollback). Find the original branch.
    # Use git branch --contains to find branches that contain the original tip,
    # then pick the one whose tip is ahead of current HEAD.
    PARENT_BRANCH=$(git -C "$SKILL_PATH" branch --contains HEAD --format='%(refname:short)' | grep -v 'detached' | head -1)
    if [ -n "$PARENT_BRANCH" ]; then
      PARENT_TIP=$(git -C "$SKILL_PATH" rev-parse "$PARENT_BRANCH")
      CURRENT_HASH=$(git -C "$SKILL_PATH" rev-parse HEAD)
      if [ "$CURRENT_HASH" != "$PARENT_TIP" ]; then
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        NEW_BRANCH="${PARENT_BRANCH}-${TIMESTAMP}"
        git -C "$SKILL_PATH" checkout -b "$NEW_BRANCH"
        echo "🔀 HEAD was detached. Created new branch: $NEW_BRANCH"
      fi
    else
      TIMESTAMP=$(date +%Y%m%d%H%M%S)
      NEW_BRANCH="main-${TIMESTAMP}"
      git -C "$SKILL_PATH" checkout -b "$NEW_BRANCH"
      echo "🔀 HEAD was detached. Created new branch: $NEW_BRANCH"
    fi
  else
    BRANCH_TIP=$(git -C "$SKILL_PATH" rev-parse "$CURRENT_BRANCH")
    CURRENT_HASH=$(git -C "$SKILL_PATH" rev-parse HEAD)
    if [ "$CURRENT_HASH" != "$BRANCH_TIP" ]; then
      TIMESTAMP=$(date +%Y%m%d%H%M%S)
      NEW_BRANCH="${CURRENT_BRANCH}-${TIMESTAMP}"
      git -C "$SKILL_PATH" checkout -b "$NEW_BRANCH"
      echo "🔀 Created new branch: $NEW_BRANCH (HEAD was behind $CURRENT_BRANCH tip)"
    fi
  fi
else
  echo "ℹ️  Nothing to commit. Working tree is clean."
  exit 0
fi

# ────────────────────────────────────────
# 7. 执行 commit
# ────────────────────────────────────────
echo "📝 Committing changes..."

if ! git -C "$SKILL_PATH" commit -m "$COMMIT_MSG"; then
  echo "❌ Error: commit failed."
  exit 1
fi

COMMIT_HASH=$(git -C "$SKILL_PATH" rev-parse --short HEAD)

echo ""
echo "✅ Changes committed successfully."
echo "   Skill: $SKILL_NAME"
echo "   Commit: $COMMIT_HASH"
echo "   Message: $COMMIT_MSG"

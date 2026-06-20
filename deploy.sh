#!/bin/bash

# 配置变量
DIST_DIR="public"          # 编译产物目录
BRANCH_NAME="gh-pages"     # 目标分支名称
WORKTREE_DIR="./quartz-deploy" # 工作树目录
COMMIT_MESSAGE="Deploy Quartz to gh-pages" # 提交信息

# 检查编译产物目录是否存在
if [ ! -d "$DIST_DIR" ]; then
  echo "错误：编译产物目录 '$DIST_DIR' 不存在。请先编译前端代码。"
  exit 1
fi

# 检查是否在 Git 仓库中
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "错误：当前目录不是一个 Git 仓库。"
  exit 1
fi

# 如果工作树不存在，创建它
if [ ! -d "$WORKTREE_DIR" ]; then
  # 如果分支不存在，创建它
  if ! git show-ref --quiet "refs/heads/$BRANCH_NAME"; then
    git checkout --orphan "$BRANCH_NAME"
    git rm -rf .
    git commit --allow-empty -m "Initial empty commit for $BRANCH_NAME"
    git checkout main
  fi
  git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
fi

# 清空工作树目录（保留 .git 目录）
find "$WORKTREE_DIR" -mindepth 1 -not -path "$WORKTREE_DIR/.git" -not -path "$WORKTREE_DIR/.git/*" -delete

# 将编译产物复制到工作树目录
cp -r "$DIST_DIR"/* "$WORKTREE_DIR/"

# 切换到工作树目录
cd "$WORKTREE_DIR" || exit 1

# 添加所有文件到暂存区
git add .

# 提交更改
git commit -m "$COMMIT_MESSAGE"

# 推送到远端 GitHub
git push origin "$BRANCH_NAME"

# 返回主目录
cd - > /dev/null

echo "部署成功！前端产物已推送到 $BRANCH_NAME 分支。"

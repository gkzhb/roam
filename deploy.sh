#!/bin/bash

# 配置变量
DIST_DIR="public"          # 编译产物目录
BRANCH_NAME="gh-pages"   # 目标分支名称
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

# 删除旧的工作树（如果存在）
if [ -d "$WORKTREE_DIR" ]; then
  git worktree remove "$WORKTREE_DIR" --force
fi

# 删除旧的 gh-pages 分支（如果存在）
if git show-ref --quiet "refs/heads/$BRANCH_NAME"; then
  git branch -D "$BRANCH_NAME"
fi

# 创建一个新的 gh-pages 分支
git checkout --orphan "$BRANCH_NAME"

# 清空分支内容
git rm -rf .

# 提交空分支
git commit --allow-empty -m "Initial empty commit for $BRANCH_NAME"

# 切换到主分支（假设主分支名称为 main）
git checkout main

# 创建工作树
git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

# 将编译产物复制到工作树目录
cp -r "$DIST_DIR"/* "$WORKTREE_DIR/"

# 切换到工作树目录
cd "$WORKTREE_DIR" || exit 1

# 添加所有文件到暂存区
git add .

# 提交更改
git commit -m "$COMMIT_MESSAGE"

# 推送到远端 GitHub
git push origin "$BRANCH_NAME" --force

# 返回主目录并清理工作树
cd - > /dev/null
git worktree remove "$WORKTREE_DIR" --force

echo "部署成功！前端产物已推送到 $BRANCH_NAME 分支。"

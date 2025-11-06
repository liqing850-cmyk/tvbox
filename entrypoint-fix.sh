#!/bin/bash
set -e

# 原逻辑前运行（echo "开始运行容器..." 等）
echo "开始运行容器..."

# 克隆仓库
git clone https://github.com/$username/$repo.git
cd $repo
git checkout main  # 或您的分支

# ... 原更新逻辑（私有化接口、写入 all.json 等）

# 修复 push：设置 remote 带 token
git remote set-url origin https://$username:$token@github.com/$username/$repo.git
git add .
git commit -m "Auto update TVBox $(date)"
git push -f origin main

echo "推送成功！"

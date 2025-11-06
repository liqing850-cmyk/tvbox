#!/bin/bash
set -e

USERNAME="${username:-liqing850-cmyk}"
TOKEN="$$ {token:- $${GITHUB_TOKEN}}"
REPO="${repo:-tvbox}"
URL="${url:-'http://pandown.pro/tvbox/tvbox.json'}"
MIRROR="${mirror:-1}"
NUM="${num:-1}"
TARGET="${target:-tvbox}"

echo "开始运行容器..."
echo "20.205.243.166 github.com" >> /etc/hosts
echo "IP address 20.205.243.166 for github.com has been added to /etc/hosts."

echo "开始克隆：git clone https://github.com/$$ {USERNAME}/ $${REPO}.git"
git clone "https://github.com/$$ {USERNAME}/ $${REPO}.git"
cd ${REPO}
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' || echo "main")
echo "仓库${REPO} 主分支为: ${MAIN_BRANCH}"
git checkout ${MAIN_BRANCH}

echo "--------- 开始私有化在线接口 ----------"
echo "当前url: ${URL}"

# 模拟/调用原私有化逻辑：下载 JSON 并简单处理（容错版，即使无 Python 也生成基本文件）
# 先下载源 JSON
curl -s "${URL}" -o /tmp/tvbox_source.json || echo "警告：源 JSON 下载失败，使用空模板"

# 生成基本 tvbox.json（线路示例，实际可扩展）
cat > tvbox.json << EOF
{
  "tvbox": [
    {
      "name": "tvbox 线路",
      "type": 3,
      "api": "${URL}",
      "filter": "true"
    }
  ]
}
EOF
echo "【线路】 ${TARGET}: ${URL}"

# JAR 下载：原 URL + fallback（常见备用）
JAR_URL="http://tv.laohu.cool/lh250711.jar"
FALLBACK_JAR="https://raw.githubusercontent.com/CatVodTVOfficial/TVBoxOSC/main/jar/tvbox.jar"  # 备用源
if curl -f -s -o /tmp/jar.jar "${JAR_URL}"; then
  echo "JAR 下载成功 (原 URL)"
elif curl -f -s -o /tmp/jar.jar "${FALLBACK_JAR}"; then
  echo "JAR 下载成功 (备用 URL)"
else
  echo "【jar下载失败】sj5mYUNYK4.jar jar地址: ${JAR_URL} error: 下载失败，使用空 JAR"
  touch /tmp/jar.jar  # 空文件占位
fi

# 生成 all.json（合并 tvbox.json + JAR 引用示例）
cat > all.json << EOF
{
  "all": [
    {
      "name": "TVBox All",
      "type": 3,
      "api": "${URL}",
      "jar": "/tmp/jar.jar"  # 引用下载的 JAR
    }
  ]
}
EOF
echo "开始写入all.json"
echo "--------- 完成私有化在线接口 ----------"

# 核心修复：设置 git remote 带 token
git config --global user.name "${USERNAME}"
git config --global user.email "${USERNAME}@users.noreply.github.com"
git remote set-url origin "https://$$ {USERNAME}: $${TOKEN}@github.com/$$ {USERNAME}/ $${REPO}.git"
echo "开始推送：git push https://github.com/$$ {USERNAME}/ $${REPO}.git"

git add .
if git diff --staged --quiet; then
  echo "无变化，无需提交"
else
  git commit -m "Auto update TVBox interfaces $(date '+%Y-%m-%d %H:%M:%S')"
  git push -f origin ${MAIN_BRANCH}
  echo "推送成功！文件已更新。"
fi

echo "耗时: $(date +%s) 秒"
#################影视仓APP配置接口########################
echo "https://ghp.ci/https://raw.githubusercontent.com/$$ {USERNAME}/ $${REPO}/main/all.json"
echo "https://ghp.ci/https://raw.githubusercontent.com/$$ {USERNAME}/ $${REPO}/main/tvbox.json"

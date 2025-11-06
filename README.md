# TVBox 私有化接口工具

[![GitHub Actions](https://github.com/你的用户名/tvbox/actions/workflows/simple-tvbox.yml/badge.svg)](https://github.com/你的用户名/tvbox/actions) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 项目描述

这个仓库基于 [fish2018/tvbox](https://github.com/fish2018/tvbox) 项目，使用 GitHub Actions 实现 **TVBox 影视接口的完全私有化**。无需本地 Docker 或任何开发环境，只需浏览器操作，即可自动下载、去重、格式化 JSON/JAR 文件，并推送至你的 GitHub 仓库。

**核心功能**：
- 支持多仓/单仓/线路接口私有化（JSON + JAR 下载）。
- 自动去重（基于 hash 和文件大小）、移除失效线路、去除 emoji。
- 支持 JS 动态渲染接口。
- 自动加速 GitHub clone/push。
- 输出 `tvbox.json`（本次线路）、`all.json`（历史总和，去重）。

**优势**：
- **零本地环境**：全在 GitHub 云端运行。
- **自动更新**：每天凌晨 3 点运行（可自定义）。
- **稳定可用**：线路经格式化，TVBox App 直接配置使用。

示例仓库： [liqing850-cmyk/tvbox](https://github.com/liqing850-cmyk/tvbox)（替换为你的用户名）。

## 快速开始

1. **Fork 或创建仓库**：在 GitHub 创建名为 `tvbox` 的空仓库（Public 推荐）。
2. **设置 Secrets**：添加 `USERNAME`（你的 GitHub 用户名）和 `TOKEN`（Personal Access Token，权限 `repo` 全选）。
3. **添加工作流**：复制下面的 YAML 到 `.github/workflows/simple-tvbox.yml`。
4. **手动运行**：Actions → Run workflow → 等待 1-3 分钟。
5. **配置 TVBox**：使用加速链接 `https://gitdl.cn/https://raw.githubusercontent.com/你的用户名/tvbox/main/tvbox.json`。

运行后，仓库会生成 `tvbox.json`、`all.json` 等文件。

## 部署步骤（网页操作，全浏览器完成）

### 步骤 1: 创建仓库
1. 登录 GitHub → 点击绿色 **New** 按钮。
2. 仓库名：`tvbox`（推荐），描述：`TVBox 私有化接口`。
3. **不要** 初始化 README 或 .gitignore（保持空仓库）。
4. **Create repository**。

### 步骤 2: 生成 Personal Access Token (PAT)
1. 头像 → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token (classic)**。
2. 描述：`tvbox-deploy`。
3. 权限：**repo**（全选子权限：contents, metadata, workflows 等）。
4. **Generate token** → **立即复制**（ghp_xxxxxxxx，一次性显示）。

### 步骤 3: 设置 Secrets
1. 仓库 → **Settings** → **Secrets and variables** → **Actions**。
2. **New repository secret**：
   - Name: `USERNAME`，Value: 你的 GitHub 用户名（e.g., liqing850-cmyk）。
   - Name: `TOKEN`，Value: 刚复制的 PAT。

### 步骤 4: 添加 GitHub Actions 工作流
1. 仓库主页 → **Add file** → **Create new file**。
2. 文件路径：`.github/workflows/simple-tvbox.yml`。
3. 粘贴以下 YAML 代码：

```yaml
name: Simple TVBox Update

on:
  schedule:
    - cron: '0 3 * * *'   # 每天凌晨 3 点自动更新（北京时间）
  workflow_dispatch:      # 允许手动触发

jobs:
  update:
    runs-on: ubuntu-latest

    steps:
      - name: Run TVBox Docker (Internal Clone & Push)
        run: |
          echo "开始运行容器..."
          docker run --rm \
            -e username=${{ secrets.USERNAME }} \
            -e token=${{ secrets.TOKEN }} \
            -e repo=tvbox \
            -e url='http://www.饭太硬.com/tv/?&signame=饭太硬' \
            -e mirror=1 \
            -e num=0 \
            2011820123/tvbox:latest

      - name: Verify Completion
        run: |
          echo "容器运行完成！刷新仓库页面查看文件。"
```

4. 底部 **Commit message**：`Add TVBox update workflow`。
5. **Commit new file**（直接 to main）。

### 步骤 5: 运行工作流
1. 仓库 → **Actions** 标签。
2. 左侧 **Simple TVBox Update** → 右上角 **Run workflow** → **Run workflow**。
3. 点击运行 job → 展开日志查看过程（1-3 分钟）。

**成功标志**：
- 日志显示 `开始克隆：git clone https://github.com/你的用户名/tvbox.git`。
- `开始写入tvbox.json` 和 `开始推送：git push`（无 403 错误）。
- 耗时 60-180 秒。

### 步骤 6: 查看生成文件
刷新仓库主页：
- `tvbox.json`：本次下载线路（默认目标文件）。
- `all.json`：历史所有线路（去重、累加）。
- `.txt` 文件：每个线路原始 JSON。
- `jar/`：JAR 文件目录（本地化）。

点击 `tvbox.json` → **Raw** 查看内容（应有 `{"sites": [...]}` 结构）。

## 配置 TVBox App

1. 打开 TVBox（猫影视、影视仓等 App）。
2. **设置** → **配置文件** → **添加**。
3. **类型**：JSON。
4. **链接**：粘贴加速版（国内快）：
   ```
   https://gitdl.cn/https://raw.githubusercontent.com/你的用户名/tvbox/main/tvbox.json
   ```
   - 历史全量：替换 `tvbox.json` 为 `all.json`。
   - 备用加速：`https://ghp.ci/https://raw.githubusercontent.com/你的用户名/tvbox/main/tvbox.json`。
5. **命名**：`我的私有仓` → **保存**。
6. **切换** 到这个配置 → **刷新** → 测试搜索/播放。

**效果**：线路去重、无失效、JAR 本地化，丝滑稳定。

## 自定义配置

编辑 `.github/workflows/simple-tvbox.yml` 的 `docker run` 部分（铅笔图标 → 修改 → Commit），然后手动 Run workflow。

### 常见参数（加在 `-e num=0 \` 后）
| 参数 | 示例 | 说明 |
|------|------|------|
| **多 URL** | `-e url='url1,url2'` | 逗号分隔多个接口，`?&signame=名称` 指定线路名。 |
| **仓库名** | `-e repo=my-tvbox` | 如果仓库名不是 `tvbox`。 |
| **下载数量** | `-e num=10` | 0=全部，前 N 条（测试用 5）。 |
| **加速镜像** | `-e mirror=10` | 1-10 级加速（国内推荐 2 或 10）。 |
| **JAR 后缀** | `-e jar_suffix=css` | 修改 JAR 文件后缀（历史批量改）。 |
| **输出文件名** | `-e target=my.json` | 生成 `my.json` 而非 `tvbox.json`。 |

**示例多线路**：
```
-e url='http://肥猫.com?&signame=肥猫,http://www.饭太硬.com/tv/?&signame=饭太硬,https://raw.githubusercontent.com/xyq254245/xyqonlinerule/main/XYQTVBox.json?&signame=香雅情' \
```

**自动更新**：默认每天 3 点。改 `cron: '0 3 * * 0'` 为周日更新。

## 故障排除

| 问题 | 日志提示 | 解决 |
|------|----------|------|
| **Docker 格式错误** | `invalid reference format` | 检查 YAML 换行（`\` 末尾，最后一行无 `\`）。用记事本重复制。 |
| **权限拒绝** | `403 / Permission denied` | 重新生成 TOKEN（repo 全选），重加 Secrets。 |
| **Python 变量错误** | `'jar' referenced before assignment` | 换稳定 URL（如单仓 `http://www.饭太硬.com/tv/`）。 |
| **镜像拉取失败** | `Unable to find image` | 加 `-e mirror=10 \`。 |
| **无文件生成** | `开始克隆` 但无 `开始写入` | URL 失效 → 换 `https://gh.con.sh/https://raw.githubusercontent.com/ouhaibo1980/tvbox/master/pg/jsm.json`。刷新页面等 10s。 |
| **运行超时** | 耗时 >300s | 设 `-e num=5` 限量测试。 |
| **Secrets 无效** | `No such device` | 确认 `USERNAME`/`TOKEN` 名全大写，无空格。 |

**调试**：Actions 日志实时查看。失败重 Run（免费额度 2000 分钟/月）。

## 更新日志

- **v1.0**：初始部署，支持单仓饭太硬线路。
- **v1.1**：添加多 URL 支持、加速参数。
- **v2.0**：集成历史累加 `all.json`。

## 贡献 & 许可证

- **贡献**：Fork → 修改 YAML → Pull Request。建议优质 URL。
- **问题**：Issues 反馈日志截图。
- **许可证**：MIT（自由使用/分享）。

**作者**：基于 fish2018/tvbox 适配。  
**联系**：GitHub Issues 或 X (@你的用户名)。

---

*最后更新：2025-11-05*  
**享受你的私有 TVBox 仓！** 🎥 如果需要二维码或更多线路，打开 Issue 告诉我。

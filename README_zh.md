# Feishu Usage Bar — 飞书用量进度条

在飞书流式卡片底部追加 MiniMax API 配额进度条，实时显示用量和剩余时间。

```
已完成 · 耗时 16.3s · MiniMax-M2.7-highspeed
↑ 260 ↓ 387 · 缓存 99% · 上下文 92.4k/200k (46%)
▓▓▓▓▓▓░░░░ 60% 3小时29分/5小时 | ▓▓▓▓░░░░░░ 42% 5天3小时/7天 | v 3/150 | s 0/150
```

## 功能

- **小时配额** — `MiniMax-M*` 每小时限额 + 剩余时间倒计时
- **周配额** — `MiniMax-M*` 7天滚动限额 + 剩余时间
- **Coding-plan 配额** — `v`（视觉模型）和 `s`（搜索）用量
- **动态颜色** — 绿 < 50%，橙 50–79%，红 ≥ 80%
- **流式卡片** — 回复过程中实时更新

## 依赖

- OpenClaw + `openclaw-lark` 插件
- `mmx` 命令行工具（[安装指南](https://github.com/MiniMax-AI/cli)）
- OpenClaw ≥ 2026.4.x（支持流式卡片）

## 一键安装

```bash
curl -sL https://raw.githubusercontent.com/VipMason/openclaw-statusline-minimax/main/install.sh | bash
```

或克隆后运行：

```bash
git clone https://github.com/VipMason/openclaw-statusline-minimax.git /tmp/feishu-usage-bar
bash /tmp/feishu-usage-bar/install.sh
```

## 卸载

```bash
bash ~/.openclaw/workspace/skills/feishu-usage-bar/install.sh --uninstall
openclaw gateway restart
```

## 手动安装

```bash
# 1. 备份原文件
cp ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js \
   ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js.bak
cp ~/.openclaw/extensions/openclaw-lark/src/card/streaming-card-controller.js \
   ~/.openclaw/extensions/openclaw-lark/src/card/streaming-card-controller.js.bak
cp ~/.openclaw/extensions/openclaw-lark/src/card/builder.js \
   ~/.openclaw/extensions/openclaw-lark/src/card/builder.js.bak

# 2. 复制补丁文件
cp patches/* ~/.openclaw/extensions/openclaw-lark/src/card/
cp patches/footer-config.js ~/.openclaw/extensions/openclaw-lark/src/core/

# 3. 修改 openclaw.json
# 在 channels.feishu 下添加：
#   footer: { tokens, cache, context, model, quota, status, elapsed }
#   streaming: true

# 4. 重启 Gateway
openclaw gateway restart
```

## 卸载

恢复备份文件后重启即可：

```bash
cp ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js.bak.YYYYMMDD \
   ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js
# 同理恢复 streaming-card-controller.js 和 builder.js
openclaw gateway restart
```

## 颜色含义

| 用量 | 颜色 |
|------|------|
| < 50% | 绿色 |
| 50–79% | 橙色 |
| ≥ 80% | 红色 |

## 作者

元旦 — 2026-05-13

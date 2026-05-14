# OpenClaw Statusline for MiniMax (Feishu Platform)

[English](./README.md) | [中文](./README_zh.md)

---

一款定制的 OpenClaw 飞书插件，在流式消息卡片底部直接显示 MiniMax API 配额使用情况，包括小时/周配额、剩余时间、颜色进度条。

## 效果预览

```
已完成 · 耗时 16.3s · MiniMax-M2.7-highspeed
↑ 260 ↓ 387 · 缓存 99% · 上下文 92.4k/200k (46%)
▓▓▓▓▓▓░░░░ 60% 3小时29分/5小时 | ▓▓▓▓░░░░░░ 42% 5天3小时/7天 | v 3/150 | s 0/150
```

## 功能特性

- **小时配额** — `MiniMax-M*` 每小时限额 + 剩余时间倒计时
- **周配额** — `MiniMax-M*` 滚动7天限额 + 剩余时间
- **编程计划配额** — `v` (VLM) 和 `s` (Search) 已用计数
- **动态颜色** — 绿色 < 50%，橙色 50–79%，红色 ≥ 80%
- **流式卡片** — 回复生成过程中实时更新

## 环境要求

- 已安装 `openclaw-lark` 插件的 OpenClaw
- `mmx` CLI（[安装指南](https://github.com/MiniMax-AI/cli)）
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

# 2. 应用补丁
git clone https://github.com/VipMason/openclaw-statusline-minimax.git /tmp/feishu-usage-bar
cp /tmp/feishu-usage-bar/patches/* \
   ~/.openclaw/extensions/openclaw-lark/src/card/
cp /tmp/feishu-usage-bar/patches/footer-config.js \
   ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js

# 3. 修改 openclaw.json
# 在 channels.feishu 中添加：
#   footer: { tokens, cache, context, model, quota, status, elapsed }
#   streaming: true

# 4. 重启
openclaw gateway restart
```

## 颜色参考

| 使用量 | 颜色 |
|--------|------|
| < 50% | 绿色 |
| 50–79% | 橙色 |
| ≥ 80% | 红色 |

## 作者

元旦 — 2026-05-13

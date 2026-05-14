# OpenClaw Statusline for MiniMax (Feishu Platform)

[English](./README.md) | [中文](./README_zh.md)

---

A customized OpenClaw Feishu plugin that displays MiniMax API quota usage directly in the streaming card footer — including hourly/weekly usage, remaining time, and color-coded progress bars.

## Preview

```
已完成 · 耗时 16.3s · MiniMax-M2.7-highspeed
↑ 260 ↓ 387 · 缓存 99% · 上下文 92.4k/200k (46%)
▓▓▓▓▓▓░░░░ 60% 3小时29分/5小时 | ▓▓▓▓░░░░░░ 42% 5天3小时/7天 | v 3/150 | s 0/150
```

## Features

- **Hourly quota** — `MiniMax-M*` per-hour limit with remaining time countdown
- **Weekly quota** — `MiniMax-M*` rolling 7-day limit with remaining time
- **Coding-plan quotas** — `v` (VLM) and `s` (Search) usage counts
- **Dynamic colors** — Green < 50%, Orange 50–79%, Red ≥ 80%
- **Streaming card** — Updates in real-time as the reply generates

## Requirements

- OpenClaw with `openclaw-lark` plugin installed
- `mmx` CLI ([install guide](https://github.com/MiniMax-AI/cli))
- OpenClaw ≥ 2026.4.x with streaming card support

## One-Line Install

```bash
curl -sL https://raw.githubusercontent.com/VipMason/openclaw-statusline-minimax/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/VipMason/openclaw-statusline-minimax.git /tmp/feishu-usage-bar
bash /tmp/feishu-usage-bar/install.sh
```

## Uninstall

```bash
bash ~/.openclaw/workspace/skills/feishu-usage-bar/install.sh --uninstall
openclaw gateway restart
```

## Manual Install

```bash
# 1. Backup original files
cp ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js \
   ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js.bak
cp ~/.openclaw/extensions/openclaw-lark/src/card/streaming-card-controller.js \
   ~/.openclaw/extensions/openclaw-lark/src/card/streaming-card-controller.js.bak
cp ~/.openclaw/extensions/openclaw-lark/src/card/builder.js \
   ~/.openclaw/extensions/openclaw-lark/src/card/builder.js.bak

# 2. Apply patches
git clone https://github.com/VipMason/openclaw-statusline-minimax.git /tmp/feishu-usage-bar
cp /tmp/feishu-usage-bar/patches/* \
   ~/.openclaw/extensions/openclaw-lark/src/card/
cp /tmp/feishu-usage-bar/patches/footer-config.js \
   ~/.openclaw/extensions/openclaw-lark/src/core/footer-config.js

# 3. Update openclaw.json
# Add to channels.feishu:
#   footer: { tokens, cache, context, model, quota, status, elapsed }
#   streaming: true

# 4. Restart
openclaw gateway restart
```

## Color Reference

| Usage | Color |
|-------|-------|
| < 50% | Green |
| 50–79% | Orange |
| ≥ 80% | Red |

## Author

元旦 — 2026-05-13

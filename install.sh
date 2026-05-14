#!/bin/bash
# Feishu Usage Bar — Installer
# Auto-detects OpenClaw environment and patches openclaw-lark plugin

set -e

CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}Feishu Usage Bar Installer${RESET}"
echo ""

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------
OS_TYPE="unknown"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
fi
echo -e "${YELLOW}Detected: $OS_TYPE${RESET}"
echo ""

# ---------------------------------------------------------------------------
# Check mmx
# ---------------------------------------------------------------------------
check_mmx() {
    if command -v mmx &> /dev/null; then
        echo -e "${GREEN}✓ mmx found${RESET}"
        return 0
    fi
    echo -e "${RED}✗ mmx not found${RESET}"
    return 1
}

install_mmx() {
    echo -e "${YELLOW}Installing mmx...${RESET}"
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}✗ npm not found. Install Node.js first: https://nodejs.org/${RESET}"
        return 1
    fi
    npm install -g @minimax-ai/mmx 2>/dev/null && \
        echo -e "${GREEN}✓ mmx installed${RESET}" && return 0
    echo -e "${RED}✗ npm install failed. Run manually: npm install -g @minimax-ai/mmx${RESET}"
    return 1
}

# ---------------------------------------------------------------------------
# Detect OpenClaw root
# ---------------------------------------------------------------------------
find_openclaw_root() {
    # Try common locations
    for dir in "$HOME/.openclaw" "/root/.openclaw"; do
        [ -d "$dir" ] && echo "$dir" && return 0
    done

    # Infer from running process
    PID=$(pgrep -f "openclaw-gateway" 2>/dev/null | head -1)
    if [ -n "$PID" ]; then
        EXE=$(readlink /proc/$PID/exe 2>/dev/null || true)
        if [ -n "$EXE" ]; then
            OCPATH=$(dirname $(dirname $EXE))
            [ -d "$OCPATH/.openclaw" ] && echo "$OCPATH/.openclaw" && return 0
        fi
    fi

    echo -e "${RED}✗ Cannot find OpenClaw directory. Is Gateway running?${RESET}" >&2
    return 1
}

# ---------------------------------------------------------------------------
# Check OpenClaw version (requires >= 2026.4.x for streaming card support)
# ---------------------------------------------------------------------------
check_openclaw_version() {
    OC_BIN=""
    for bin in openclaw "$HOME/.openclaw/bin/openclaw" "/usr/local/bin/openclaw"; do
        if command -v "$bin" &> /dev/null; then
            OC_BIN="$bin"
            break
        fi
    done

    if [ -z "$OC_BIN" ]; then
        echo -e "${YELLOW}⚠ Cannot check version — openclaw CLI not in PATH${RESET}"
        echo -e "   Please ensure OpenClaw >= 2026.4.x is installed"
        return 0
    fi

    VER=$("$OC_BIN" --version 2>/dev/null | head -1 || echo "")
    # Accept 2026.4.x or higher
    if echo "$VER" | grep -qE '^2026\.([4-9]|[0-9]{2,})'; then
        echo -e "${GREEN}✓ OpenClaw version: $VER${RESET}"
    else
        echo -e "${RED}✗ OpenClaw version too old: $VER${RESET}"
        echo -e "   This plugin requires OpenClaw >= 2026.4.x for streaming card support"
        echo -e "   Please upgrade: https://docs.openclaw.ai/getting-started/installation${RESET}"
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Find openclaw-lark plugin
# ---------------------------------------------------------------------------
find_lark_dir() {
    EXT_DIR="$1/extensions"

    for dir in "$EXT_DIR/openclaw-lark" "$EXT_DIR/openclaw-lark.disabled"; do
        [ -d "$dir/src" ] && echo "$dir" && return 0
    done

    echo -e "${RED}✗ openclaw-lark plugin not found${RESET}" >&2
    return 1
}

# ---------------------------------------------------------------------------
# Uninstall: restore backups
# ---------------------------------------------------------------------------
do_uninstall() {
    echo -e "${CYAN}Feishu Usage Bar — Uninstall${RESET}"
    echo ""

    OPENCLAW_ROOT=$(find_openclaw_root) || exit 1
    LARK_DIR=$(find_lark_dir "$OPENCLAW_ROOT") || exit 1
    BACKUP_DIR=$(ls -td "$LARK_DIR"/src.bak.*/ 2>/dev/null | head -1)

    if [ -z "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}No backup found. Nothing to uninstall.${RESET}"
        return 0
    fi

    echo -e "${YELLOW}Restoring from: $BACKUP_DIR${RESET}"
    cp "$BACKUP_DIR/footer-config.js" "$LARK_DIR/src/core/footer-config.js" && \
        echo -e "${GREEN}✓ footer-config.js${RESET}"
    cp "$BACKUP_DIR/streaming-card-controller.js" "$LARK_DIR/src/card/streaming-card-controller.js" && \
        echo -e "${GREEN}✓ streaming-card-controller.js${RESET}"
    cp "$BACKUP_DIR/builder.js" "$LARK_DIR/src/card/builder.js" && \
        echo -e "${GREEN}✓ builder.js${RESET}"

    echo ""
    echo -e "${YELLOW}Restart Gateway to complete uninstall:${RESET}"
    echo "   openclaw gateway restart"
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if [[ "$1" == "--uninstall" || "$1" == "-u" ]]; then
    do_uninstall
    exit 0
fi
if ! check_mmx; then
    echo ""
    read -p "Install mmx now? [Y/n] " -n 1 -r reply
    echo ""
    [[ "${reply:-Y}" =~ ^[Yy]$ ]] && install_mmx
fi

echo ""
echo -e "${CYAN}==> Finding OpenClaw...${RESET}"
OPENCLAW_ROOT=$(find_openclaw_root) || exit 1
echo -e "${GREEN}✓ OpenClaw: $OPENCLAW_ROOT${RESET}"

echo -e "${CYAN}==> Finding openclaw-lark plugin...${RESET}"
LARK_DIR=$(find_lark_dir "$OPENCLAW_ROOT") || exit 1
echo -e "${GREEN}✓ Plugin: $LARK_DIR${RESET}"

# Enable if disabled
if [[ "$LARK_DIR" == *.disabled ]]; then
    NEW_DIR="${LARK_DIR%.disabled}"
    mv "$LARK_DIR" "$NEW_DIR"
    LARK_DIR="$NEW_DIR"
    echo -e "${GREEN}✓ Plugin enabled${RESET}"
fi

# Version check
echo ""
echo -e "${CYAN}==> Checking OpenClaw version...${RESET}"
check_openclaw_version

# ---------------------------------------------------------------------------
# Backup
# ---------------------------------------------------------------------------
echo ""
echo -e "${CYAN}==> Backing up files...${RESET}"
TS=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="$LARK_DIR/src.bak.$TS"
mkdir -p "$BACKUP_DIR"

backup() {
    SRC=$1
    [ -f "$SRC" ] && cp "$SRC" "$BACKUP_DIR/$(basename $SRC)" && \
        echo -e "${GREEN}✓ Backed up $(basename $SRC)${RESET}"
}
backup "$LARK_DIR/src/core/footer-config.js"
backup "$LARK_DIR/src/card/streaming-card-controller.js"
backup "$LARK_DIR/src/card/builder.js"
echo -e "${YELLOW}  (backup: $BACKUP_DIR)${RESET}"

# ---------------------------------------------------------------------------
# Apply patches
# ---------------------------------------------------------------------------
echo ""
echo -e "${CYAN}==> Applying patches...${RESET}"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCHES_DIR="$SKILL_DIR/patches"

cp "$PATCHES_DIR/footer-config.js" "$LARK_DIR/src/core/footer-config.js" && \
    echo -e "${GREEN}✓ footer-config.js${RESET}"
cp "$PATCHES_DIR/streaming-card-controller.js" "$LARK_DIR/src/card/streaming-card-controller.js" && \
    echo -e "${GREEN}✓ streaming-card-controller.js${RESET}"
cp "$PATCHES_DIR/builder.js" "$LARK_DIR/src/card/builder.js" && \
    echo -e "${GREEN}✓ builder.js${RESET}"

# ---------------------------------------------------------------------------
# Syntax check
# ---------------------------------------------------------------------------
echo ""
echo -e "${CYAN}==> Validating syntax...${RESET}"
for f in "footer-config.js" "streaming-card-controller.js" "builder.js"; do
    case "$f" in
        footer-config.js) FP="$LARK_DIR/src/core/$f" ;;
        *) FP="$LARK_DIR/src/card/$f" ;;
    esac
    if node --check "$FP" 2>/dev/null; then
        echo -e "${GREEN}✓ $f OK${RESET}"
    else
        echo -e "${RED}✗ $f syntax error${RESET}" && exit 1
    fi
done

# ---------------------------------------------------------------------------
# Update openclaw.json
# ---------------------------------------------------------------------------
echo ""
echo -e "${CYAN}==> Updating openclaw.json...${RESET}"
OPENCLAW_JSON="$OPENCLAW_ROOT/openclaw.json"

python3 - "$OPENCLAW_JSON" "$LARK_DIR" << 'PYEOF'
import json, sys

json_path = sys.argv[1]
lark_dir = sys.argv[2]

with open(json_path, "r") as f:
    d = json.load(f)

plugins = d.get("plugins", {})

# add to allow list
allow = plugins.setdefault("allow", [])
if "openclaw-lark" not in allow:
    allow.append("openclaw-lark")

# add to load paths
paths = plugins.setdefault("load", {}).setdefault("paths", [])
if lark_dir not in paths:
    paths.append(lark_dir)

# footer + streaming config
feishu = d.setdefault("channels", {}).setdefault("feishu", {})
feishu["footer"] = {
    "tokens": True, "cache": True, "context": True,
    "model": True, "quota": True, "status": True, "elapsed": True
}
feishu["streaming"] = True

accounts = feishu.get("accounts", {})
if "main" in accounts:
    accounts["main"]["footer"] = feishu["footer"].copy()

with open(json_path, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

print(f"  Config written to {json_path}")
PYEOF

# ---------------------------------------------------------------------------
# Restart
# ---------------------------------------------------------------------------
echo ""
echo -e "${CYAN}==> Restarting Gateway...${RESET}"
if command -v openclaw &> /dev/null; then
    openclaw gateway restart 2>/dev/null && \
        echo -e "${GREEN}✓ Gateway restarted${RESET}" || \
        echo -e "${YELLOW}⚠ Gateway restart failed — run manually: openclaw gateway restart${RESET}"
fi

echo ""
echo -e "${GREEN}✅ Done!${RESET}"
echo "   Send a message to your Feishu bot — the quota bar will appear at the bottom."
echo ""

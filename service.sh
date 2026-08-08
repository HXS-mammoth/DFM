#!/system/bin/sh
# DFM Block Pro v2.0 - 开机自启动
# 更激进清理 + hosts 阻断

MODDIR=${0%/*}
PKG="com.tencent.tmgp.dfm"
DATA_DIR="/data/data/$PKG"
SD_DIR="/storage/emulated/0/Android/data/$PKG"
SD_OBB="/storage/emulated/0/Android/obb/$PKG"
TMP_DIR="/data/local/tmp"
LOG="$MODDIR/log.txt"
HOSTS_FILE="/system/etc/hosts"
CUSTOM_HOSTS="$MODDIR/system/etc/hosts"
INTERVAL=5

# 更激进的关键词（坐标加密、反作弊、上报、应用列表相关）
BLOCK_PATTERNS="
AntiCheat ACE anticheat AntiCheatExpert
coord encrypt keydata security tprt tp2
beacon report telemetry crashpad
applist packagelist installed_apps app_list
deviceinfo fingerprint reportlog
tprt2 gamesafe ace_sdk
"

log() {
    echo "$(date '+%m-%d %H:%M:%S') $1" >> "$LOG"
}

# ========== hosts 阻断 ==========
apply_hosts() {
    if [ -f "$CUSTOM_HOSTS" ]; then
        # 通过 Magisk/KernelSU 系统挂载覆盖
        # 模块 system/etc/hosts 会自动生效
        log "[HOSTS] 自定义 hosts 已挂载"
    fi
}

# ========== 激进清理 ==========
clean_aggressive() {
    local base="$1"
    [ ! -d "$base" ] && return

    for pat in $BLOCK_PATTERNS; do
        find "$base" -maxdepth 8 -type f \( -iname "*${pat}*" \) 2>/dev/null | while read -r f; do
            case "$f" in
                *.so|*.apk|*.odex|*.vdex|*.art|*.dex) continue ;;
            esac
            rm -f "$f" 2>/dev/null && log "[DEL] $f"
        done
    done

    # 额外清理空目录和临时上报文件
    find "$base" -maxdepth 6 -type f \( -name "*.tmp" -o -name "*.log" -o -name "*report*" -o -name "*upload*" \) 2>/dev/null | while read -r f; do
        rm -f "$f" 2>/dev/null && log "[DEL-TMP] $f"
    done
}

# 清理系统 tmp 中与游戏相关的临时文件
clean_tmp() {
    find "$TMP_DIR" -maxdepth 2 -type f \( -iname "*dfm*" -o -iname "*delta*" -o -iname "*tmgp*" -o -iname "*applist*" -o -iname "*packagelist*" \) 2>/dev/null | while read -r f; do
        rm -f "$f" 2>/dev/null && log "[DEL-TMP] $f"
    done
}

# 尝试锁定高风险目录写权限（游戏运行时）
lock_dirs() {
    for d in "$DATA_DIR/files" "$DATA_DIR/cache" "$DATA_DIR/code_cache" \
             "$SD_DIR/files" "$SD_DIR/cache"; do
        [ -d "$d" ] && chmod 555 "$d" 2>/dev/null
    done
}

unlock_dirs() {
    for d in "$DATA_DIR/files" "$DATA_DIR/cache" "$DATA_DIR/code_cache" \
             "$SD_DIR/files" "$SD_DIR/cache"; do
        [ -d "$d" ] && chmod 755 "$d" 2>/dev/null
    done
}

# ========== 主逻辑 ==========
log "===== DFM Block Pro v2.0 启动 ====="
apply_hosts

# 首次强制清理
clean_aggressive "$DATA_DIR"
clean_aggressive "$SD_DIR"
clean_aggressive "$SD_OBB"
clean_tmp

while true; do
    if pidof "$PKG" >/dev/null 2>&1 || pgrep -f "$PKG" >/dev/null 2>&1; then
        # 游戏运行中：激进清理 + 锁目录
        clean_aggressive "$DATA_DIR"
        clean_aggressive "$SD_DIR"
        clean_tmp
        lock_dirs
    else
        unlock_dirs
    fi
    sleep $INTERVAL
done

#!/bin/bash
# Smart monitor setup for GDM
# Reads the user's primary monitor from monitors.xml,
# falls back to the best available connected output if missing.

GDM_MONITORS_FILE="/var/lib/gdm3/.config/monitors.xml"
PRIMARY=""

# Extract primary output name from monitors.xml
get_primary_from_config() {
    if [ -f "$GDM_MONITORS_FILE" ]; then
        awk -F'"' '/<output name=/{name=$2} /<primary>yes</{print name}' "$GDM_MONITORS_FILE" | tail -1
    fi
}

# 1. Try to read primary from user config
if [ -f "$GDM_MONITORS_FILE" ]; then
    PRIMARY=$(get_primary_from_config)
    if [ -n "$PRIMARY" ]; then
        if ! xrandr | grep -q "^$PRIMARY connected"; then
            PRIMARY=""   # not connected, fallback
        fi
    fi
fi

# 2. Fallback: pick best connected output
if [ -z "$PRIMARY" ]; then
    CONNECTED=$(xrandr | grep " connected" | awk '{print $1}')
    for port in $CONNECTED; do
        if echo "$port" | grep -qiE 'vga|hdmi|dp|displayport'; then
            PRIMARY=$port
            break
        fi
    done
    if [ -z "$PRIMARY" ]; then
        PRIMARY=$(echo "$CONNECTED" | head -1)
    fi
fi

# 3. Nothing connected? Exit
if [ -z "$PRIMARY" ]; then
    exit 0
fi

# 4. Turn off all other outputs
for output in $(xrandr | grep " connected" | awk '{print $1}'); do
    if [ "$output" != "$PRIMARY" ]; then
        xrandr --output "$output" --off
    fi
done

# 5. Enable and set primary
xrandr --output "$PRIMARY" --primary --auto

exit 0
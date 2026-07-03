#!/bin/bash
# Copies the user's monitors.xml to GDM's config directory

GDM_CONFIG_DIR="/var/lib/gdm3/.config"
USER_MONITORS_FILE="$HOME/.config/monitors.xml"

if [ -f "$USER_MONITORS_FILE" ]; then
    sudo mkdir -p "$GDM_CONFIG_DIR"
    sudo cp "$USER_MONITORS_FILE" "$GDM_CONFIG_DIR/"
    sudo chown gdm:gdm "$GDM_CONFIG_DIR/monitors.xml"
fi
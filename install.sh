#!/bin/bash
set -e

echo "=== Installing GDM Multi-Monitor Fix ==="

# 1. Disable Wayland in GDM
if grep -q "^WaylandEnable=false" /etc/gdm3/custom.conf; then
    echo "✓ Wayland already disabled."
else
    echo "Disabling Wayland..."
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
    if ! grep -q "^WaylandEnable=false" /etc/gdm3/custom.conf; then
        echo "WaylandEnable=false" | sudo tee -a /etc/gdm3/custom.conf > /dev/null
    fi
fi

# 2. Install GDM script
sudo cp auto-monitor-setup.sh /usr/share/gdm/greeter/autostart/auto-monitor-setup.sh
sudo chmod +x /usr/share/gdm/greeter/autostart/auto-monitor-setup.sh
echo "✓ GDM script installed."

# 3. Install user script
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
if [ -z "$USER_HOME" ]; then
    echo "! SUDO_USER empty. Are you running with sudo?"
    exit 1
fi

mkdir -p "$USER_HOME/.local/bin"
cp update-gdm-monitors.sh "$USER_HOME/.local/bin/"
chmod +x "$USER_HOME/.local/bin/update-gdm-monitors.sh"
chown $SUDO_USER:$SUDO_USER "$USER_HOME/.local/bin/update-gdm-monitors.sh"

mkdir -p "$USER_HOME/.config/autostart"
cat > "$USER_HOME/.config/autostart/update-gdm-monitors.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Update GDM Monitor Config
Exec=$USER_HOME/.local/bin/update-gdm-monitors.sh
Icon=preferences-desktop-display
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
chown $SUDO_USER:$SUDO_USER "$USER_HOME/.config/autostart/update-gdm-monitors.desktop"
echo "✓ User script and autostart entry created."

# 4. Initial sync
sudo -u $SUDO_USER "$USER_HOME/.local/bin/update-gdm-monitors.sh"
echo "✓ Current monitor settings copied to GDM."
echo "=== Installation complete. Log out and back in, then reboot. ==="
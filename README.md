# GDM Multi-Monitor Fix

Fixes the GDM login screen appearing on the wrong monitor or staying black
when using both an integrated GPU (iGPU) and a discrete GPU (dGPU).

## The Problem
GDM may place the login dialog on the iGPU output while the dGPU monitor
shows only a black screen with a cursor, or vice versa. Unplugging one
monitor causes the dialog to jump around, but plugging both back makes
the issue return.

## The Solution
A script that runs when GDM starts:
- Reads your primary monitor from your user's `monitors.xml` settings.
- If that monitor is disconnected, it automatically picks the best
  available connected output (preferring VGA, HDMI, DP).
- Turns off all other outputs so GDM always shows the login screen on
  a single, correct monitor.
- After login, your desktop uses your normal multi-monitor layout again.

A companion user script, run via autostart, keeps GDM's configuration
in sync with your latest monitor arrangement.

## Requirements
- A GNOME-based distro with GDM (Ubuntu, Zorin OS, Pop!_OS, etc.)
- GDM must use Xorg (Wayland disabled) — the installer does this for you.
- `xrandr` (installed by default on these systems).

## Installation
```bash
git clone https://github.com/MiladBhrlo/gdm-monitor-fix.git
cd gdm-monitor-fix
chmod +x install.sh
sudo ./install.sh
```

After installation, log out and back in, then reboot.
On next boot, the login screen will appear on your preferred monitor.

Files

· auto-monitor-setup.sh   – runs at GDM startup to configure outputs.
· update-gdm-monitors.sh  – copies your monitor settings to GDM on every login.
· install.sh              – automated installer.
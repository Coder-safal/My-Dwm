# My-Dwm

My personal [dwm](https://dwm.suckless.org/) (Dynamic Window Manager) setup — kept here as a backup so I can restore the exact same desktop on any new machine.

This repo bundles everything needed for a complete suckless-style Linux desktop:

| Tool         | What it is                                              |
| ------------ | ------------------------------------------------------- |
| `dwm-6.4`    | The window manager — tiles your windows, draws the bar  |
| `luke-smith-st` | The terminal emulator (Luke Smith's `st` build)      |
| `dmenu-5.2`  | The application launcher (`Mod + p`)                    |
| `slstatus`   | The text shown on the right side of the bar             |
| `libxft-bgra`| Patched libXft so the bar/terminal can render emoji 🙂  |
| `scripts/`   | Helper scripts bound to keys (volume, brightness, etc.) |

---

## 1. What you need before starting

A fresh Debian-based Linux (Ubuntu, Pop!_OS, Linux Mint, etc.) with:

- A working internet connection (we'll download fonts and dependencies)
- `sudo` access on your user account
- About **500 MB** of free disk space
- An X11 session (this does **not** work on Wayland-only systems)

> If you're not sure whether you have X11: run `echo $XDG_SESSION_TYPE` in a terminal. It should print `x11`. If it prints `wayland`, you'll need to install an X server first (`sudo apt install xorg`).

---

## 2. Quick install (the easy way)

This is the recommended path for a fresh machine. It does everything for you.

### Step 1 — Get the repo

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/<your-github-username>/My-Dwm.git ~/My-Dwm
```

> Replace `<your-github-username>` with the actual repo URL. If you copied the folder by USB/scp instead, just make sure it ends up at `~/My-Dwm` (i.e. `/home/<you>/My-Dwm`).

### Step 2 — Open the install script and fix two lines

The script has my username and path hard-coded. Open it and change them to match your machine:

```bash
nano ~/My-Dwm/install.sh
```

Find these two lines near the top and edit them:

```bash
REPO=/home/safal/My-Dwm     # ← change "safal" to your username
REAL_USER=safal             # ← change to your username
```

Save with `Ctrl+O`, `Enter`, then `Ctrl+X`.

### Step 3 — Run the installer

```bash
sudo bash ~/My-Dwm/install.sh
```

It will:

1. Install all build tools (gcc, X11 dev headers, etc.)
2. Remove any previous dwm/st/dmenu binaries
3. Download and install the **MesloLGM Nerd Font** (used by the bar)
4. Build and install `libxft-bgra` (so emojis render correctly)
5. Build and install `dwm`, `st`, `dmenu`, and `slstatus`

This takes about **3–5 minutes** on a normal machine. At the end you'll see a green "All done" banner.

### Step 4 — Log out and pick DWM as your session

1. Log out of your current desktop
2. On the login screen, click the **gear/settings icon** next to your username (or near the password field)
3. Choose **DWM** from the list
4. Log in

You're done. The bar appears at the bottom (or is hidden — toggle with `Mod + b`).

---

## 3. Manual install (if you want to understand each step)

Skip this section if the quick install worked.

```bash
# 1. Dependencies
sudo apt install -y build-essential pkg-config \
  libx11-dev libxft-dev libxinerama-dev libharfbuzz-dev libfontconfig1-dev \
  xorg-dev xutils-dev autoconf libtool unzip wget git \
  fonts-noto-color-emoji copyq

# 2. Build the emoji-capable libXft (shadows the system one)
cd ~/My-Dwm/libxft-bgra
autoreconf -fvi --install
./configure --prefix=/usr/local --sysconfdir=/etc --mandir=/usr/share/man
make -j$(nproc)
sudo make install
sudo ldconfig

# 3. Build dwm
cd ~/My-Dwm/dwm-6.4
make -j$(nproc)
sudo make install

# 4. Build st
cd ~/My-Dwm/luke-smith-st
make -j$(nproc)
sudo make install

# 5. Build dmenu
cd ~/My-Dwm/dmenu-5.2
make -j$(nproc)
sudo make install

# 6. Build slstatus
cd ~/My-Dwm/slstatus
make -j$(nproc)
sudo make install
```

Then log out and pick **DWM** at the login screen.

---

## 4. Starting DWM the right way (auto-restart on rebuild)

When you tweak `config.h` and rebuild, you usually want DWM to **restart automatically** so the new build kicks in without a logout. The included [`scripts/dwmReload.sh`](scripts/dwmReload.sh) does exactly that.

Create or edit `~/.xinitrc` (or your session startup file) and use this as the line that launches dwm:

```bash
exec bash ~/My-Dwm/scripts/dwmReload.sh
```

Now whenever you `sudo make install` a new dwm, the script notices the binary changed and restarts dwm in place — no logout needed.

---

## 5. Customizing — the most common thing you'll change

dwm is configured by **editing C source code and recompiling**. There is no config file you reload at runtime. This sounds scary; it's actually two steps:

### To change a setting:

1. Open [`dwm-6.4/config.h`](dwm-6.4/config.h)
2. Change a value (font, color, keybinding, gap, etc.)
3. Rebuild:

```bash
cd ~/My-Dwm/dwm-6.4
sudo make clean install
```

4. If you set up `dwmReload.sh` (above), the new version is live instantly. Otherwise log out and back in.

### Common tweaks

| What you want to change   | Line to edit in `config.h`                         |
| ------------------------- | -------------------------------------------------- |
| Show/hide bar by default  | `static const int showbar = 0;` (1 = show)         |
| Bar on top instead of bottom | `static const int topbar = 0;` (1 = top)        |
| Window border thickness   | `static const unsigned int borderpx = 0;`          |
| Font / size               | `static const char *fonts[]`                       |
| Colors                    | `sel_fg`, `sel_bg`, `norm_fg`, `norm_bg`, etc.     |
| Browser for `Mod + r`     | `static const char *brave[] = {"brave-browser",…}` |

---

## 6. Keybindings cheat-sheet

`MOD` = **Alt** (left Alt key). `SUPER` = **Windows / Super key**.

### Launching apps

| Keys              | Action                       |
| ----------------- | ---------------------------- |
| `MOD + p`         | dmenu (app launcher)         |
| `MOD + e`         | Open `st` terminal           |
| `MOD + r`         | Open Brave browser           |
| `MOD + y`         | Open Google Chrome           |
| `SUPER + e`       | Open Nemo file manager       |
| `SUPER + c`       | Open CopyQ clipboard menu    |
| `SUPER + s/d/f`   | Toggle scratchpads (term / notes / music) |

### Window management

| Keys                  | Action                              |
| --------------------- | ----------------------------------- |
| `MOD + b`             | Toggle bar visibility               |
| `MOD + j` / `MOD + k` | Focus next / previous window        |
| `MOD + Tab`           | Cycle window focus                  |
| `MOD + Return`        | Promote focused window to master    |
| `MOD + h` / `MOD + l` | Shrink / grow master area           |
| `MOD + i` / `MOD + d` | More / fewer windows in master area |
| `MOD + Space`         | Toggle layout                       |
| `MOD + Shift + Space` | Toggle floating for current window  |
| `MOD + c`             | Close focused window                |
| `MOD + Shift + q`     | Quit dwm (logout)                   |

### Layouts

| Keys             | Layout            |
| ---------------- | ----------------- |
| `MOD + m`        | Monocle (fullscreen-ish) |
| `MOD + Shift + m`| Tile              |
| `MOD + Ctrl + m` | Floating          |

### Tags (workspaces 1–9)

| Keys                          | Action                              |
| ----------------------------- | ----------------------------------- |
| `MOD + 1..9`                  | Switch to tag                       |
| `MOD + Shift + 1..9`          | Move focused window to tag          |
| `MOD + Ctrl + 1..9`           | Toggle tag visibility               |
| `MOD + 0`                     | Show windows on all tags            |
| `SUPER + Left` / `SUPER + Right` | Rotate through tags              |

### System / media

| Keys                       | Action              |
| -------------------------- | ------------------- |
| `MOD + Ctrl + Up / Down`   | Volume up / down    |
| `XF86 Volume keys`         | Volume up / down    |
| `MOD + Ctrl + Right / Left`| Brightness up / down |
| `SUPER + m`                | Mute / unmute       |
| `MOD + Ctrl + p`           | Switch audio output |
| `MOD + Ctrl + c`           | Switch audio profile |
| `SUPER + Shift + s`        | Screenshot (clip)   |
| `SUPER + Ctrl + s`         | Screenshot (full)   |
| `MOD + Ctrl + r`           | Screen recording    |
| `MOD + Ctrl + v`           | Voice recording     |
| `SUPER + .`                | Emoji picker        |
| `MOD + Ctrl + b`           | Change wallpaper    |
| `MOD + z` / `MOD + Ctrl + z` | Increase / decrease transparency |

---

## 7. Helper scripts

The keybindings above call scripts in [`scripts/`](scripts/). Copy that folder to `~/scripts` (the keybindings expect that path):

```bash
cp -r ~/My-Dwm/scripts ~/scripts
chmod +x ~/scripts/*
```

You'll also want these extra programs installed for the scripts to work:

```bash
sudo apt install -y \
  brightnessctl pulseaudio-utils \
  maim xclip xdotool \
  ffmpeg \
  feh \
  rofi
```

---

## 8. Troubleshooting

**The bar shows squares instead of emoji.**
The system `libXft` is being used instead of the patched one. Re-run step 4 of the installer, then `sudo ldconfig`. Verify with:
```bash
ldd /usr/local/bin/dwm | grep libXft
```
It should point to `/usr/local/lib/libXft.so.*`, not `/lib/x86_64-linux-gnu/`.

**DWM doesn't appear at the login screen.**
The `.desktop` file is usually installed by `make install`. If missing, create `/usr/share/xsessions/dwm.desktop`:
```
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=dwm
Type=Application
```

**`make` fails with "no fonts could be loaded".**
The Nerd Font isn't installed. Re-run step 3 of the installer, or install manually:
```bash
mkdir -p /usr/share/fonts/truetype/meslo-nerd
cd /tmp && wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
sudo unzip Meslo.zip -d /usr/share/fonts/truetype/meslo-nerd
sudo fc-cache -f
```

**Black screen after login.**
DWM started but nothing was launched. Press `MOD + e` to open a terminal, or `MOD + p` for dmenu. To auto-start things on login, create `~/.xprofile`:
```bash
#!/bin/bash
picom &
slstatus &
nm-applet &
```

**I changed `config.h` and nothing happened.**
You forgot to recompile. Always run `sudo make clean install` from `dwm-6.4/` after editing.

---

## 9. Pushing this repo to GitHub (first time only)

If you've made changes locally and want to publish them to your own GitHub repo, run these commands from inside the project folder:

```bash
cd ~/My-Dwm

# Initialize git in this folder (only the first time)
git init

# Stage everything
git add .

# Create the first commit (paste the whole block — the message is intentionally detailed)
git commit -m "Initial commit: complete personal DWM desktop setup

Bundles dwm-6.4, luke-smith-st, dmenu-5.2, and slstatus together with the
libxft-bgra shadow library so the bar and terminal render color emoji
correctly. Includes a fully scripted installer (install.sh), a custom
config.h with scratchpads, brightness/volume/audio keybindings, screenshot
and screen-recording helpers, and a beginner-friendly README covering
install, customization, keybindings, and troubleshooting."

# Default branch name = main
git branch -M main

# Point at your GitHub repo (SSH)
git remote add origin git@github.com:Coder-safal/My-Dwm.git

# Push it up
git push -u origin main
```

> **Heads-up about SSH:** the `git@github.com:...` URL needs an SSH key already linked to your GitHub account. If you've never set one up on this machine, do this once:
> ```bash
> ssh-keygen -t ed25519 -C "your-email@example.com"
> cat ~/.ssh/id_ed25519.pub
> ```
> Copy the printed key and paste it into GitHub → **Settings → SSH and GPG keys → New SSH key**.
> Prefer HTTPS instead? Replace the remote URL with `https://github.com/Coder-safal/My-Dwm.git` — GitHub will ask for a personal access token the first time you push.

### Pushing later updates

After the first push, the workflow shrinks to three commands:

```bash
git add .
git commit -m "describe what you changed"
git push
```

---

## 10. Uninstall

```bash
sudo rm -f /usr/local/bin/{dwm,st,dmenu,dmenu_run,dmenu_path,stest,slstatus}
sudo rm -f /usr/local/lib/libXft*
sudo apt-get install --reinstall libxft2 libxft-dev
sudo ldconfig
```

Then pick a different session at the login screen.

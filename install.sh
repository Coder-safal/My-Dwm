#!/usr/bin/env bash
# Full reinstall of suckless stack from /home/safal/My-Dwm/.
# Replaces the binaries at /usr/local/bin/{dwm,st,dmenu}, installs slstatus,
# installs MesloLGM Nerd Font and shadows system libXft with libxft-bgra so
# color emoji render in dwm/st/dmenu.
#
# Run as:   sudo bash /home/safal/My-Dwm/install.sh
#
# Reversible by:
#   sudo apt-get install --reinstall libxft2 libxft-dev
#   sudo rm -f /usr/local/lib/libXft*  /usr/local/bin/{dwm,st,dmenu,slstatus}
#   sudo ldconfig

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run with sudo: sudo bash $0" >&2
  exit 1
fi

REPO=/home/safal/My-Dwm
REAL_USER=safal
LOG_PREFIX=$'\n\033[1;36m==>\033[0m '

step() { echo "${LOG_PREFIX}$*"; }

step "1/8  Installing build dependencies"
apt-get update
apt-get install -y \
  build-essential pkg-config \
  libx11-dev libxft-dev libxinerama-dev libharfbuzz-dev libfontconfig1-dev \
  xorg-dev xutils-dev autoconf libtool unzip wget git \
  fonts-noto-color-emoji \
  copyq

step "2/8  Removing old dwm/st/dmenu binaries and stale build artifacts"
rm -f /usr/local/bin/dwm /usr/local/bin/st /usr/local/bin/dmenu /usr/local/bin/dmenu_run /usr/local/bin/dmenu_path /usr/local/bin/stest /usr/local/bin/slstatus
rm -f /usr/local/share/man/man1/dwm.1 /usr/local/share/man/man1/st.1 /usr/local/share/man/man1/dmenu.1 /usr/local/share/man/man1/stest.1 /usr/local/share/man/man1/slstatus.1
# clean any *.o left in source trees so we get a fresh build
for d in "$REPO/dwm-6.4" "$REPO/luke-smith-st" "$REPO/dmenu-5.2" "$REPO/slstatus"; do
  (cd "$d" && make clean >/dev/null 2>&1 || true)
done

step "3/8  Installing MesloLGM Nerd Font"
FONT_DIR=/usr/share/fonts/truetype/meslo-nerd
if [[ ! -d "$FONT_DIR" ]]; then
  TMP=$(mktemp -d)
  wget -q --show-progress -O "$TMP/Meslo.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  mkdir -p "$FONT_DIR"
  unzip -q -o "$TMP/Meslo.zip" -d "$FONT_DIR"
  rm -rf "$TMP"
  fc-cache -f >/dev/null
  echo "   installed to $FONT_DIR"
else
  echo "   already present at $FONT_DIR (skipping)"
fi

step "4/8  Fetching & building libxft-bgra (shadows system libXft via /usr/local/lib)"
LIBXFT_DIR="$REPO/libxft-bgra"
if [[ -z "$(ls -A "$LIBXFT_DIR" 2>/dev/null || true)" ]]; then
  # empty dir — clone source into it
  sudo -u "$REAL_USER" git clone --depth=1 https://github.com/uditkarode/libxft-bgra "$LIBXFT_DIR.tmp"
  shopt -s dotglob
  mv "$LIBXFT_DIR.tmp"/* "$LIBXFT_DIR"/
  rmdir "$LIBXFT_DIR.tmp"
  shopt -u dotglob
fi
cd "$LIBXFT_DIR"
# libtoolize on this upstream sometimes places ltmain.sh in the parent dir;
# move it into the source dir before running autoreconf.
if [[ ! -f ltmain.sh && -f ../ltmain.sh ]]; then
  mv ../ltmain.sh ./
fi
# Re-run autoreconf if any expected generated file is missing.
# (A previous failed run can leave ./configure present but Makefile.in absent.)
if [[ ! -f configure || ! -f Makefile.in || ! -f src/Makefile.in ]]; then
  sudo -u "$REAL_USER" autoreconf -fvi --install || true
  # if libtoolize again pushed ltmain.sh into ../, pull it back and retry
  if [[ ! -f ltmain.sh && -f ../ltmain.sh ]]; then
    mv ../ltmain.sh ./
    sudo -u "$REAL_USER" autoreconf -fvi --install
  fi
fi
sudo -u "$REAL_USER" ./configure --prefix=/usr/local --sysconfdir=/etc --mandir=/usr/share/man
sudo -u "$REAL_USER" make -j"$(nproc)"
make install
ldconfig
echo "   libXft now resolves to: $(ldconfig -p | grep -m1 'libXft\.so\.2 ' | awk '{print $NF}')"

step "5/8  Building & installing dwm-6.4"
cd "$REPO/dwm-6.4"
sudo -u "$REAL_USER" make -j"$(nproc)"
make install
echo -n "   dwm libXft -> "; ldd /usr/local/bin/dwm | awk '/libXft/ {print $3}'

step "6/8  Building & installing st (luke-smith-st)"
cd "$REPO/luke-smith-st"
sudo -u "$REAL_USER" make -j"$(nproc)"
make install
echo -n "   st  libXft -> "; ldd /usr/local/bin/st | awk '/libXft/ {print $3}'

step "7/8  Building & installing dmenu-5.2"
cd "$REPO/dmenu-5.2"
sudo -u "$REAL_USER" make -j"$(nproc)"
make install
echo -n "   dmenu libXft -> "; ldd /usr/local/bin/dmenu | awk '/libXft/ {print $3}'

step "8/8  Building & installing slstatus"
cd "$REPO/slstatus"
sudo -u "$REAL_USER" make -j"$(nproc)"
make install
echo "   slstatus installed: $(command -v slstatus)"

echo
echo "============================================================"
echo "  All done."
echo "  Installed binaries:"
ls -l /usr/local/bin/dwm /usr/local/bin/st /usr/local/bin/dmenu /usr/local/bin/slstatus
echo
echo "  Log out of this X session and log back in (pick 'Dwm' from GDM)"
echo "  to start the freshly built dwm. A reboot also works."
echo "============================================================"

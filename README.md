<h1 align="center">
  <img src="icons/openra-ca.png" alt="OpenRA - Combined Arms" width="200">
  <br />
  OpenRA - Combined Arms - Snap
</h1>

[![openra-combined-arms](https://snapcraft.io/openra-combined-arms/badge.svg)](https://snapcraft.io/openra-combined-arms)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[![Get it from the Snap Store](https://snapcraft.io/en/light/install.svg)](https://snapcraft.io/openra-combined-arms)

---

## 📦 About the Snap

This is a **Snap package** for **OpenRA - Combined Arms**, a modern remake of Command & Conquer games powered by the OpenRA engine.

Play a standalone mod with unique features, enhanced visuals, and a reimagined RTS experience.

This snap provides a **sandboxed and secure runtime environment**, limiting access to system resources while ensuring compatibility across Linux distributions via Snap’s universal packaging.

---

## 🚀 Build Locally (Manual)

```bash
cd snap
snapcraft clean
snapcraft pack
```

---

## 📦 Install Locally Built Version

```bash
sudo snap install --dangerous snap/openra-combined-arms_1.08.2_amd64.snap
```

---

## 🛠️ Development with Makefile (Recommended)

A Makefile is included to simplify development, testing, and iteration.

### 🔹 First-time setup

```bash
make build
make install
make smoke
```

---

### 🔹 Normal development loop

```bash
make build
make refresh
make smoke
```

---

### 🔹 Fast loop

```bash
make dev
```

---

### 🔹 If something breaks

```bash
make clean
make build
make reinstall
```

---

### 🔹 Full non-interactive verification

```bash
make test-all
```

---

### 🔹 Useful commands

```bash
make run          # launch the game
make logs         # follow snap logs
make connections  # inspect interfaces
```

---

### 🔹 Cleanup

```bash
make clean            # clear snapcraft build state
make clean-artifacts  # remove built .snap files
make clean-all        # both
```

---

## 🛒 Install from Snap Store

### Stable

```bash
sudo snap install openra-combined-arms
```

### Beta

```bash
sudo snap install openra-combined-arms --beta
```

---

## 📥 Extra Game Data

To enable access to original Command & Conquer game data (e.g. discs or external storage):

```bash
sudo snap connect openra-combined-arms:mount-observe
sudo snap connect openra-combined-arms:removable-media
```

---

## 📚 Useful Links

- GitHub Repository: https://github.com/Inq8/CAmod  
- ModDB Page: https://www.moddb.com/mods/command-conquer-combined-arms

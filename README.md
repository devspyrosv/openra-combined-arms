<h1 align="center">
  <img src="icons/openra-ca.png" alt="OpenRA - Combined Arms" width="200">
  <br />
  OpenRA - Combined Arms - Snap
</h1>

[![cnc-combined-arms](https://snapcraft.io/cnc-combined-arms/badge.svg)](https://snapcraft.io/cnc-combined-arms) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)


### About the Snap

This is a **Snap package** for **OpenRA - Combined Arms**, a modern remake of Command & Conquer games powered by the OpenRA engine. 

Play a standalone mod with unique features, enhanced visuals, and a reimagined RTS experience.

This snap was created to provide a safer and more secure way to enjoy OpenRA - Combined Arms. By confining the game within a sandboxed environment, the snap limits its access to system resources, ensuring that it can run safely without interfering with your operating system or accessing sensitive data. This approach not only enhances security but also makes the game easier to install and run across different Linux distributions, leveraging the convenience of Snap's universal packaging format.

---

## 🚀 Build Locally

```bash
snapcraft clean && snapcraft
```

## 📦 Install Locally Built Version
```bash
sudo snap install --dangerous combined-arms_1.04_amd64.snap
```

## 🛒 Install from the Snap Store
> coming soon...

## 📥 Extra Game Data
To add game data from original Command & Conquer game discs, you can allow mounting optical drives. Run the following commands:

```bash
sudo snap connect combined-arms:mount-observe
sudo snap connect combined-arms:removable-media
```

## 📚 Useful Links


Combined Arms GitHub Repository: <a href="https://github.com/Inq8/CAmod"><img src="https://img.shields.io/badge/GitHub-Repository-blue?logo=github" alt="GitHub Repository"></a>


Combined Arms ModDB Page: <a href="https://www.moddb.com/mods/command-conquer-combined-arms"><img src="https://img.shields.io/badge/moddb-Command%20%26%20Conquer%20Combined%20Arms-red" alt="ModDB Link"></a>


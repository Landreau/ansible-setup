# Guide d’installation

Ce projet provisionne une machine de dev Debian/Ubuntu ou Arch. Points clés:
- Debian/Ubuntu: APT non interactif, dépôt GitHub CLI, Starship via script
- Arch: optimisation miroirs, AUR via `yay`, `dwm-git`, Wireshark `wireshark-qt`, remaps (`python3→python`, `tldr→tealdeer`)
- Préflight non bloquant pour signaler la dispo des paquets

## 0) Prérequis
- Debian 11+/Ubuntu 22.04+ ou Arch Linux
- Utilisateur sudo (par défaut `Landreau`, modifiable dans `vars.yml`)
- Accès Internet

## 1) One‑liner (recommandé)

Option A — via le script bootstrap hébergé dans votre dépôt (remplacez <owner>/<repo>):
```bash
REPO_URL="https://github.com/<owner>/<repo>.git" bash -c "$(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/bootstrap.sh)"
```

Option B — one‑liner direct (sans script distant), à adapter selon votre distro:

Debian/Ubuntu:
```bash
bash -c 'set -e; sudo apt update; sudo apt install -y git ansible python3; REPO_URL="https://github.com/<owner>/<repo>.git"; DEST="${REPO_URL##*/}"; DEST="${DEST%.git}"; rm -rf "$DEST"; git clone "$REPO_URL" "$DEST"; cd "$DEST"; ansible-galaxy collection install -U community.general; sudo -v; ansible-playbook setup.yml'
```

Arch:
```bash
bash -c 'set -e; sudo pacman -Sy --needed --noconfirm git ansible python; REPO_URL="https://github.com/<owner>/<repo>.git"; DEST="${REPO_URL##*/}"; DEST="${DEST%.git}"; rm -rf "$DEST"; git clone "$REPO_URL" "$DEST"; cd "$DEST"; ansible-galaxy collection install -U community.general; sudo -v; ansible-playbook setup.yml'
```

## 2) Installation manuelle (si vous préférez)

1) Installer Ansible et Git
- Debian/Ubuntu:
  ```bash
  sudo apt update
  sudo apt install -y python3 ansible git
  ```
- Arch:
  ```bash
  sudo pacman -Sy --needed python ansible git
  ```

2) Cloner le dépôt:
```bash
git clone https://github.com/<owner>/<repo>.git
cd <repo>
```

3) Vérifier/adapter `vars.yml` (utilisateur, features, etc.)

4) Collection Ansible requise:
```bash
ansible-galaxy collection install -U community.general
```

5) Lancer le playbook:
```bash
sudo -v
ansible-playbook setup.yml
```

## 3) Après l’installation
- Ouvrir un nouveau terminal (zsh, starship, etc.)
- Rejoindre immédiatement le groupe wireshark dans la session:
  ```bash
  newgrp wireshark
  ```
- Vérifications rapides: `gh --version`, `code --version`, `lvim --version`, `dwm` (Arch), etc.

## 4) Dépannage
- Erreur pacman “could not find or read package”: nom Debian utilisé côté Arch. Les remaps principaux sont gérés; si vous ajoutez de nouveaux paquets, adaptez les noms par distro.
- `yay` demande le mot de passe: le drop‑in sudoers se crée lors du premier run; la première exécution demande le mot de passe sudo.
- APT prompts: playbook en mode non‑interactif; Wireshark preseedé.
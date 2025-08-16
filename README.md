# Ansible Dev Workstation (Debian/Ubuntu + Arch)

Playbook pour provisionner une machine de dev:
- Debian/Ubuntu: APT non‑interactif, Starship via script, dépôt GitHub CLI
- Arch: optimisation miroirs, AUR via `yay`, `dwm-git`, Wireshark (`wireshark-qt`), remaps (`python3→python`, `tldr→tealdeer`)
- Préflight non bloquant

## One‑liner
Remplacez `<owner>/<repo>`:
```bash
REPO_URL="https://github.com/<owner>/<repo>.git" bash -c "$(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/bootstrap.sh)"
```

Ou suivez docs/INSTALL.md pour d’autres options.
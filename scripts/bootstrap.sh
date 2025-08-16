#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${REPO_URL:-}"
BRANCH="${BRANCH:-main}"
DEST_DIR="${DEST_DIR:-}"
ASK_SUDO="${ASK_SUDO:-true}"

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"

have() { command -v "$1" >/dev/null 2>&1; }

detect_pkg_mgr() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
      *arch*|*manjaro*|*endeavouros*) echo "pacman" ;;
      *debian*|*ubuntu*|*linuxmint*|*pop*) echo "apt" ;;
      *) echo "unknown" ;;
    esac
  else
    echo "unknown"
  fi
}

PKG_MGR="$(detect_pkg_mgr)"
if [ "$PKG_MGR" = "unknown" ]; then
  echo "Erreur: distribution non reconnue. Support: Debian/Ubuntu ou Arch." >&2
  exit 1
fi

install_packages() {
  case "$PKG_MGR" in
    apt)
      sudo apt-get update -y
      sudo apt-get install -y --no-install-recommends ca-certificates curl git python3 python3-pip ansible
      ;;
    pacman)
      sudo pacman -Sy --noconfirm --needed ca-certificates curl git python ansible
      ;;
  esac
}

ensure_ansible() {
  if ! have ansible || ! have ansible-playbook; then
    echo "Ansible manquant, tentative via gestionnaire..."
    install_packages || true
  fi
  if ! have ansible || ! have ansible-playbook; then
    echo "Fallback: installation via pipx..."
    if ! have pipx; then
      python3 -m pip install --user -U pipx || python -m pip install --user -U pipx
      python3 -m pipx ensurepath || true
      export PATH="$HOME/.local/bin:$PATH"
    fi
    pipx install --force ansible
  fi
  if ! have ansible || ! have ansible-playbook; then
    echo "Impossible d'installer Ansible automatiquement." >&2
    exit 1
  fi
}

if [ "$ASK_SUDO" = "true" ]; then
  echo "Validation sudo (mot de passe demandé une fois si nécessaire)..."
  sudo -v
fi

install_packages || true
ensure_ansible

if [ -f "setup.yml" ] && [ -d "tasks" ]; then
  REPO_DIR="$(pwd)"
else
  if [ -z "${REPO_URL}" ]; then
    echo "REPO_URL n'est pas défini et aucun setup.yml trouvé dans le répertoire courant." >&2
    echo "Définissez REPO_URL (ex: https://github.com/<owner>/<repo>.git) ou lancez ce script depuis le dépôt cloné."
    exit 1
  fi
  if [ -z "$DEST_DIR" ]; then
    DEST_DIR="${REPO_URL##*/}"
    DEST_DIR="${DEST_DIR%.git}"
  fi
  rm -rf "$DEST_DIR"
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$DEST_DIR"
  REPO_DIR="$DEST_DIR"
fi

cd "$REPO_DIR"

ansible-galaxy collection install -U community.general

echo "Lancement du playbook..."
ansible-playbook setup.yml

echo "Terminé. Ouvrez un nouveau terminal ou déconnectez-vous/reconnectez-vous pour appliquer les changements (zsh par défaut, groupe wireshark, etc.)."

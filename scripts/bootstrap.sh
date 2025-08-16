#!/usr/bin/env bash
# Bootstrap cross-distro: installe Ansible + Git, clone le dépôt et lance le playbook.
# Utilisation (recommandé) :
#   REPO_URL="https://github.com/<owner>/<repo>.git" bash -c "$(curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/bootstrap.sh)"
# Ou en local si vous avez déjà cloné le repo :
#   ./scripts/bootstrap.sh  (dans ce cas, REPO_URL est ignoré et on suppose que setup.yml est dans le répertoire courant)

set -euo pipefail

# -------- Paramètres --------
REPO_URL="${REPO_URL:-}"             # Ex: https://github.com/<owner>/<repo>.git
BRANCH="${BRANCH:-main}"
DEST_DIR="${DEST_DIR:-}"              # Par défaut: nom du repo (dérivé de REPO_URL)
ASK_SUDO="${ASK_SUDO:-true}"          # true: valider sudo au début pour éviter les prompts; false: ne pas faire sudo -v

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"

have() { command -v "$1" >/dev/null 2>&1; }

# -------- Détection OS / gestionnaire de paquets --------
detect_pkg_mgr() {
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
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
  echo "Erreur: distribution non reconnue. Support: Debian/Ubuntu ou Arch."
  exit 1
fi

# -------- Installation dépendances --------
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

# -------- Préparation sudo --------
if [ "$ASK_SUDO" = "true" ]; then
  echo "Validation sudo (mot de passe demandé une fois si nécessaire)..."
  sudo -v
fi

# -------- Installer Ansible/Git --------
install_packages || true
ensure_ansible

# -------- Récupération du dépôt --------
if [ -f "setup.yml" ] && [ -d "tasks" ]; then
  # On est déjà dans le repo
  REPO_DIR="$(pwd)"
else
  if [ -z "${REPO_URL}" ]; then
    echo "REPO_URL n'est pas défini et aucun setup.yml trouvé dans le répertoire courant."
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

# -------- Collections Ansible requises --------
ansible-galaxy collection install -U community.general

# -------- Lancer le playbook --------
echo "Lancement du playbook..."
# sudo -v a déjà amorcé le cache, pas besoin de -K
ansible-playbook setup.yml

echo "Terminé. Ouvrez un nouveau terminal ou déconnectez-vous/reconnectez-vous pour appliquer les changements (zsh par défaut, groupe wireshark, etc.)."
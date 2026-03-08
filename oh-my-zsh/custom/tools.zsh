# tools.zsh — Tool Belt integrations

echo "📂 Configuring Tools : $0  [dth for help]"

# --- Config ---
TOOL_BELT_DIR="$HOME/Development/git-hub/tool-belt/tool-belt"

# --- tool-belt: directory_tree ---
dtree() {
  local target="${1:-.}"
  python "$TOOL_BELT_DIR/scripts/directory_tree.py" "$target"
}

# --- Help ---
dth() {
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;32m            Tools Help                           \e[0m"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;33mdtree\e[0m         : Show directory tree (default: current dir)"
  echo -e "\e[1;33mdtree <path>\e[0m  : Show directory tree for <path>"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
}

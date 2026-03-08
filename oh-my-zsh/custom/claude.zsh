# ~/.oh-my-zsh/custom/claude_settings.zsh

# --- Initialization Check ---
echo "📂 Configuring Claude : $0  [ch for help]"

# --- 1. Claude Help Command ---
ch() {
  # \e[1;32m is Bold Green, \e[1;34m is Bold Blue, \e[0m resets color
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;32m       CLAUDE CUSTOM COMMANDS MENU                \e[0m"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;33mcc\e[0m  : Launch standard Claude"
  echo -e "\e[1;33mh\e[0m   : Launch Claude with Haiku model (Fast)"
  echo -e "\e[1;33mcx\e[0m  : Launch Claude & skip all permissions"
  echo -e "\e[1;33mcv\e[0m  : Launch Claude in Voice-Optimized mode"
  echo -e "\e[1;33mcdi\e[0m : Launch Claude with local diagram context"
  echo -e "\e[1;33mcss\e[0m : Sync global Claude standards into this project"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
}

# --- 2. Core Aliases ---
alias cc="claude"
alias h="claude --model haiku"
alias cx="claude --dangerously-skip-permissions"

# --- 3. Voice-First Optimized Mode ---
alias cv="claude --dangerously-skip-permissions --append-system-prompt 'Voice mode: stay concise, skip preambles, and use spoken-style language.'"

# --- 4. Tools from your Screenshot ---
alias ghv="gh repo view --web"
alias ghcp='GH_PAGER="" gh repo view --json name,owner --jq "\"https://github.com/\" + .owner.login"'
alias mcpi="bunx @modelcontextprotocol/inspector@latest"

# --- 5. Logic Functions ---
css() {
  bash ~/Development/git-hub/tool-belt/scripts/claude-standards-sync.sh
  echo "Claude standards synced to .claude/standards/"
  echo ""
  echo "Ensure your project CLAUDE.md contains:"
  echo ""
  echo "  ## Global Standards"
  echo "  @.claude/standards/_INDEX.md"
}


unalias cdi 2>/dev/null
cdi() {
  local docs="./ai/diagrams/**/*.md"
  if ls $docs >/dev/null 2>&1; then
    claude --append-system-prompt "$(cat $docs)"
  else
    echo "No diagrams found. Starting standard Claude..."
    claude
  fi
}

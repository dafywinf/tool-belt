# Claude Code shell config — baked into the devcontainer image.
# Sourced automatically by Oh-my-zsh (all *.zsh in custom/ are loaded).
#
# Container-specific Claude shell config for this devcontainer template.
# Keep this file tracked directly in the repo.

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
  echo -e "\e[1;33mct\e[0m      : Launch Claude in Teleport mode"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
}

# --- 2. Core Aliases ---
alias cc="claude"                                    # Standard Claude
alias h="claude --model haiku"                       # Haiku model (fast)
alias cx="claude --dangerously-skip-permissions"     # Skip all permission prompts

# --- 3. Voice-First Optimized Mode ---
# Skips permissions and injects a system prompt for concise spoken-style responses
alias cv="claude --dangerously-skip-permissions --append-system-prompt 'Voice mode: stay concise, skip preambles, and use spoken-style language.'"

# --- 4. Tools ---
alias ghv="gh repo view --web"                       # Open repo in browser
alias ghcp='GH_PAGER="" gh repo view --json name,owner --jq "\"https://github.com/\" + .owner.login"'  # Copy repo URL
alias mcpi="bunx @modelcontextprotocol/inspector@latest"  # Launch MCP Inspector

# --- 5. Logic Functions ---

# cdi: Launch Claude with local diagram context injected as a system prompt
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

# --- 6. Teleport Mode ---
alias ct="claude --teleport"                         # Launch Claude in Teleport mode

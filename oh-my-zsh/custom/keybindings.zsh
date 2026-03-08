# keybindings.zsh — Custom key bindings
echo "📂 Configuring Keybindings : $0"

# Ctrl+→ : accept next word of autosuggestion
# (two sequences cover different terminal emulators)
bindkey '\e[1;5C' forward-word
bindkey '\e[5C'   forward-word

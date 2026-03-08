# kubernetes.zsh — Kubernetes & DevOps aliases
echo "📂 Configuring Kubernetes : $0  [kh for help]"

# --- kubectl ---
alias k="kubectl"
alias kgp="kubectl get pods"
alias kl="kubectl logs -f"

# --- Helm ---
alias hm="helm"

# --- ArgoCD ---
alias argo="argocd"
alias argol="argocd login cd.example.com"

# --- Help ---
kh() {
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;32m      KUBERNETES CUSTOM COMMANDS MENU             \e[0m"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;33mk\e[0m     : kubectl"
  echo -e "\e[1;33mkgp\e[0m   : kubectl get pods"
  echo -e "\e[1;33mkl\e[0m    : kubectl logs -f"
  echo -e "\e[1;33mhm\e[0m    : helm"
  echo -e "\e[1;33margo\e[0m  : argocd"
  echo -e "\e[1;33margol\e[0m : argocd login cd.example.com"
  echo -e "\e[1;33mkh\e[0m    : Show this help"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
}

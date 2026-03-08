# java.zsh — Java environment configuration
echo "📂 Configuring Java : $0  [jh for help]"

export PATH="/usr/local/opt/openjdk@21/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Switch to JDK 8 when needed
function jdk8 {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
  export PATH="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/bin:$PATH"
}

alias jv="java --version"

jh() {
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;32m         JAVA CUSTOM COMMANDS MENU                \e[0m"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "\e[1;33mjv\e[0m   : Show current Java version"
  echo -e "\e[1;33mjdk8\e[0m : Switch to JDK 8"
  echo -e "\e[1;33mjh\e[0m   : Show this help"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
  echo -e "Active: \e[1;32m$JAVA_HOME\e[0m"
  echo -e "\e[1;34m--------------------------------------------------\e[0m"
}


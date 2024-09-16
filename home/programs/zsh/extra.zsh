# Disable glob qualification
# which causes zsh to treat square brackets as glob patterns
setopt no_bare_glob_qual

case "$(uname -s)" in
  Darwin)
    export ANDROID_HOME=$HOME/Library/Android/sdk
    ;;

  Linux)

    export ANDROID_HOME=$HOME/Android/Sdk
    ;;

esac

# load the asdf direnv plugin that was setup with
# `asdf direnv setup --no-touch-rc-file --shell zsh --version system`
# NOTE: what is confusing here is that this asdf plugin
# is mainly used to load .tool-versions runtimes
# when a .envrc specifies it with `use asdf`
# BUT also provides `direnv` runtimes, which makes
# no sense as direnv must be installed globally
# (otherwise it poses a chicken-and-egg problem)
source "${HOME}/.config/asdf-direnv/zshrc"

export KEYTIMEOUT=1
export PATH=~/bin:~/.local/bin/:~/.ghcup/bin:$PATH

# add platformio path
export PATH=$PATH:~/.platformio/penv/bin

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# cargo
export PATH=$PATH:~/.cargo/bin

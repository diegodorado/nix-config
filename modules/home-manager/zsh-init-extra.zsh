case "$(uname -s)" in
  Darwin)
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

    export ANDROID_HOME=$HOME/Library/Android/sdk
    #load asdf
    source "$(brew --prefix asdf)/libexec/asdf.sh"
    ;;

  Linux)

    # now pbcopy and pbpaste works the same on both OSes
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'

    export ANDROID_HOME=$HOME/Android/Sdk
    #load asdf
    . /opt/asdf-vm/asdf.sh
    ;;

esac

# load asdf direnv
source "${HOME}/.config/asdf-direnv/zshrc"

ghpr() { GH_FORCE_TTY=100% gh pr list --limit 300 |
    fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window 'down,70%' --header-lines 3 |
    awk '{print $1}' |
    xargs gh pr checkout; }

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

# silent direnv
export DIRENV_LOG_FORMAT=

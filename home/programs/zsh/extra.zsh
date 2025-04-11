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
#jai
export PATH=$PATH:~/Code/jai/bin

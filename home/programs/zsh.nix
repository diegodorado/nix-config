{ config, pkgs, lib, ... }:

{

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      wormhole = "wormhole-william";
      mm = "fd 'jpg|gif' ~/Pictures | fzf | xargs wezterm imgcat";
      ls = "ls --color=auto -F";
      hm = "pushd ~/Code/nix-config; nix run .#activate-home; popd; source ~/.zshrc;";
      nixswitch = "darwin-rebuild switch --flake ~/Code/nix-config/.#";
      nixup = "pushd ~/Code/nix-config; nix flake update; nixswitch; popd";
      cp = "cp -i"; # Confirm before overwriting something
      df = "df -h"; # Human-readable sizes
      free = "free -m"; # Show sizes in MB
      open = "xdg-open";
      cat = "bat";
      g = "git";
      lg = "lazygit";
      v = "nvim";
      gcob = "git branch | fzf | xargs git checkout";
    };
    plugins = [ ];
    initExtra = ''
            '' + (builtins.readFile ../../modules/home-manager/zsh-init-extra.zsh);
    envExtra = ''
            '';
  };


}

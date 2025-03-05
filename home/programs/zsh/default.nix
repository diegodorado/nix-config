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
      hm = "pushd ~/Code/nix-config; nix run .\#homeConfigurations.diegodorado.activationPackage; popd; source ~/.zshrc;";
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
      jai = "jai-macos";
    };
    plugins = [ ];
    initExtra = ''
      . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
      autoload -Uz bashcompinit && bashcompinit
      . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
      ${(builtins.readFile ./extra.zsh)}
    '';
    envExtra = ''
            '';
  };


}

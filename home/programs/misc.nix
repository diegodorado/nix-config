{ config, pkgs, lib, ... }:

{
  programs.bat.enable = true;
  # programs.bat.config.theme = "Catppuccin";
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.gpg.enable = true;

  programs.mpv = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # runtimes and env manager without shims (better asdf)
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  # better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
  };
}

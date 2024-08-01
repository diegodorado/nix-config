{ config, pkgs, lib, ... }:

{

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[❯](bold fg:#ff33b8) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };


}

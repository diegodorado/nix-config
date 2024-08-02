{ config, pkgs, lib, ... }:

let
  catppuccinTheme = pkgs.runCommand "catppuccin-mocha-yazi"
    {
      src = pkgs.fetchgit {
        url = "https://github.com/yazi-rs/flavors.git";
        rev = "main";
        sparseCheckout = [ "catppuccin-mocha.yazi" ];
        hash = "sha256-9hw6+yDI1KMl0e33ZMnFlitS9eE/dG5qW8b+E7k5Oks=";
      };
    } ''
    ln -s $src/catppuccin-mocha.yazi $out
  '';
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # FIXME!
    # flavors = {
    #   "catppuccin-mocha.yazi" = catppuccinTheme;
    # };
    # theme = {
    #   flavor = {
    #     use = "catppuccin-mocha";
    #   };
    # };
  };


}

{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # shellWrapperName = "yy";
    flavors = {
      "catppuccin-mocha.yazi" =
        let
          fetchCatppuccin = pkgs.fetchgit {
            url = "https://github.com/yazi-rs/flavors.git";
            rev = "main";
            sparseCheckout = [
              "catppuccin-mocha.yazi"
            ];
            hash = "sha256-9hw6+yDI1KMl0e33ZMnFlitS9eE/dG5qW8b+E7k5Oks=";
          };
        in
        pkgs.runCommand "move-catppuccin" { } ''
          cp -r ${fetchCatppuccin}/catppuccin-mocha.yazi $out
        '';
    };

    theme = {
      # flavor = {
      #   use = "catppuccin-mocha";
      # };
    };
  };


}

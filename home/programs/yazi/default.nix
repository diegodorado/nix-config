{ config, lib, pkgs, ... }:

let
  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "main";
    sha256 = "sha256-/EUaaL08K3F0J0Rn9+XgfKm+W8tekdiWsGxkd892BO8=";
  };

  glow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "main";
    sha256 = "sha256-NcMbYjek99XgWFlebU+8jv338Vk1hm5+oW5gwH+3ZbI=";
  };

  exifaudio = pkgs.fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "master";
    sha256 = "sha256-mYvq7xnd4gI0KoG5G+ygDxqCWdpZbMn3Im1EiW3eSyI=";
  };

in
{
  # required packages for plugins
  home.packages = with pkgs; [ exiftool glow ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      plugin = {
        prepend_previewers = [
          { name = "*.md"; run = "glow"; }
          { mime = "audio/*"; run = "exifaudio"; }
        ];
      };
    };
    theme = {
      flavor = {
        use = "catppuccin-mocha";
      };
    };

    flavors = {
      catppuccin-mocha = "${flavors}/catppuccin-mocha.yazi";
    };

    plugins = {
      glow = glow;
      exifaudio = exifaudio;
    };
  };

}

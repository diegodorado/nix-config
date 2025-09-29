{ config, lib, pkgs, ... }:

let
  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "main";
    sha256 = "sha256-+awiEG5ep0/6GaW8YXJ7FP0/xrL4lSrJZgr7qjh8iBc=";
  };

  glow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "main";
    sha256 = "sha256-mzW/ut/LTEriZiWF8YMRXG9hZ70OOC0irl5xObTNO40=";
  };

  exifaudio = pkgs.fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "master";
    sha256 = "sha256-RWCqWBpbmU3sh/A+LBJPXL/AY292blKb/zZXGvIA5/o=";
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

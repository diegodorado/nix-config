{ config, lib, pkgs, ... }:

let
  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "main";
    sha256 = "sha256-Tpu/BLs/P/5KipggGQM8je1BpLpEDVBSAb5qZPXea1k=";
  };

  glow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "main";
    sha256 = "sha256-fKJ5ld5xc6HsM/h5j73GABB5i3nmcwWCs+QSdDPA9cU=";
  };

  exifaudio = pkgs.fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "master";
    sha256 = "sha256-8f1iG9RTLrso4S9mHYcm3dLKWXd/WyRzZn6KNckmiCc=";
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

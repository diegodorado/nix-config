{ config, lib, pkgs, ... }:

with lib;

let
  tomlFormat = pkgs.formats.toml { };

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

  zshIntegration = ''
    function ${cfg.shellWrapperName}() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';

  cfg = {
    enable = true;
    shellWrapperName = "yy";
    enableZshIntegration = true;
    keymap = { };
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
    initLua = null;
  };

in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ yazi exiftool glow ];

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration zshIntegration;

    xdg.configFile = {
      "yazi/keymap.toml" = mkIf (cfg.keymap != { }) {
        source = tomlFormat.generate "yazi-keymap" cfg.keymap;
      };
      "yazi/yazi.toml" = mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "yazi-settings" cfg.settings;
      };
      "yazi/theme.toml" = mkIf (cfg.theme != { }) {
        source = tomlFormat.generate "yazi-theme" cfg.theme;
      };
      "yazi/init.lua" = mkIf (cfg.initLua != null)
        (if builtins.isPath cfg.initLua then {
          source = cfg.initLua;
        } else {
          text = cfg.initLua;
        });

      # flavors
      "yazi/flavors/catppuccin-mocha.yazi".source = "${flavors}/catppuccin-mocha.yazi";
      # plugins
      "yazi/plugins/glow.yazi".source = "${glow}";
      "yazi/plugins/exifaudio.yazi".source = "${exifaudio}";

    };

  };

}

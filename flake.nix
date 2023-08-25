{
  description = "minimal flake";
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Controls system level software and settings including fonts
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

    # some GL apps needs to be wrapped...
    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }:
    let
      myUserName = "diegodorado";
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      nixgl = import inputs.nixgl { pkgs = pkgs; };
      nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
        echo My example command is running

        mkdir $out
        ln -s ${pkg}/* $out
        echo "HOLAAAAAA"
        rm $out/bin
        echo "$out"
        mkdir $out/bin
        for bin in ${pkg}/bin/*; do
         wrapped_bin=$out/bin/$(basename $bin)
         echo "exec ${pkgs.lib.getExe (nixgl.nixGLCommon nixgl.nixGLIntel)} $bin \$@" > $wrapped_bin
         chmod +x $wrapped_bin
        done
      '';
    in

    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [ inputs.nixos-flake.flakeModule ];

      perSystem = { pkgs, ... }: {
        legacyPackages.homeConfigurations.${myUserName} =
          self.nixos-flake.lib.mkHomeConfiguration
            pkgs
            ({ pkgs, ... }: {
              imports = [ self.homeModules.default ];
              home.username = myUserName;
              home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${myUserName}";
              home.stateVersion = "22.11";
            });
      };


      flake = {

        formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

        # Configurations for macOS machines
        darwinConfigurations.dd-m1 = self.nixos-flake.lib.mkMacosSystem {
          nixpkgs.hostPlatform = "aarch64-darwin";
          imports = [
            # Your nix-darwin configuration goes here
            ({ pkgs, ... }: {
              security.pam.enableSudoTouchIdAuth = true;
              # Used for backwards compatibility, please read the changelog before changing.
              # $ darwin-rebuild changelog
              system.stateVersion = 4;
            })
            # Setup home-manager in nix-darwin config
            self.darwinModules.home-manager
            {
              home-manager.users.${myUserName} = {
                imports = [ self.homeModules.default ];
                home.stateVersion = "22.11";
              };
            }
          ];
        };

        # home-manager configuration goes here.
        homeModules.default = { pkgs, ... }: {
          imports = [ ];

          # This value determines the Home Manager release that your configuration is
          # compatible with. This helps avoid breakage when a new Home Manager release
          # introduces backwards incompatible changes.
          #
          # You should not change this value, even if you update Home Manager. If you do
          # want to update the value, then make sure to first check the Home Manager
          # release notes.
          home.stateVersion = "22.11"; # Please read the comment before changing.

          # The home.packages option allows you to install Nix packages into your
          # environment.
          home.packages = with pkgs; [
            curl
            fd
            fzf
            less
            nil #lsp for nix
            # rnix-lsp #another one
            ripgrep
            helix
            jq
            just
            go
            nushell
            lazygit
            htop

            # # It is sometimes useful to fine-tune packages, for example, by applying
            # # overrides. You can do that directly here, just don't forget the
            # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
            # # fonts?
            # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

            # # You can also create simple shell scripts directly inside your
            # # configuration. For example, this adds a command 'my-hello' to your
            # # environment:
            # (pkgs.writeShellScriptBin "my-hello" ''
            #   echo "Hello, ${config.home.username}!"
            # '')
          ];

          # Home Manager is pretty good at managing dotfiles. The primary way to manage
          # plain files is through 'home.file'.
          home.file = {
            # # Building this configuration will create a copy of 'dotfiles/screenrc' in
            # # the Nix store. Activating the configuration will then make '~/.screenrc' a
            # # symlink to the Nix store copy.
            # ".screenrc".source = dotfiles/screenrc;

            # # You can also set the file content immediately.
            # ".gradle/gradle.properties".text = ''
            #   org.gradle.console=verbose
            #   org.gradle.daemon.idletimeout=3600000
            # '';
          };

          home.sessionVariables = {
            PAGER = "less";
            CLICOLOR = 1;
            EDITOR = "hx";
          };

          programs.wezterm = {
            enable = true;
            enableZshIntegration = true;
                          extraConfig = ''
               local wezterm = require 'wezterm'      
               return {
                 font_size = 16,
                 color_scheme = 'Everforest Dark (Gogh)',
                 window_background_opacity = 1.0,
                 hide_tab_bar_if_only_one_tab = true,
               }
              '';

          };

          programs.kitty.enable = true;
          # programs.kitty.package = nixGLWrap pkgs.kitty;


          programs.bat.enable = true;
          programs.bat.config.theme = "TwoDark";
          programs.fzf.enable = true;
          programs.fzf.enableZshIntegration = true;
          programs.exa.enable = true;
          programs.gpg.enable = true;
          programs.git = {
            enable = true;
            userEmail = "diegodorado@gmail.com";
            userName = "Diego Dorado";
            aliases = {
              co = "checkout";
              cp = "cherry-pick";
              fix = "hx $(git diff --name-only --relative --diff-filter=U | uniq)";
              cm = "commit";
              cma = "commit --amend";
              pf = "push --force-with-lease";
              ll = "log --oneline";
            };
            delta = {
              enable = true;
              options = {
                syntax-theme = "base16-256";
                navigate = true;
                features = "line-numbers decorations";
                plus-style = ''syntax "#003f01"'';
                minus-style = ''syntax "#3f0001"'';
              };
            };
            signing = {
              signByDefault = true;
              key = "~/.ssh/id_${if pkgs.stdenv.isDarwin then "ed25519" else "rsa" }.pub";
            };
            extraConfig = {
              core.editor = "hx";
              push.default = "simple";
              push.autoSetupRemote = true;
              gui.spellingdictionary = "none";
              gpg.format = "ssh";
            };
          };

          programs.atuin = {
            enable = true;
            enableZshIntegration = true;
            flags = [ "--disable-up-arrow" ];
          };

          programs.zsh = {
            enable = true;
            defaultKeymap = "viins";
            enableCompletion = true;
            enableAutosuggestions = true;
            syntaxHighlighting.enable = true;
            shellAliases = {
              ls = "ls --color=auto -F";
              hm = "home-manager --flake ~/Code/nix-config/.";
              hmb = "home-manager build --flake ~/Code/nix-config/.#diegodorado";
              hms = "home-manager switch --flake ~/Code/nix-config/.#diegodorado && exec zsh";
              nixswitch = "darwin-rebuild switch --flake ~/Code/nix-config/.#";
              nixup = "pushd ~/Code/nix-config; nix flake update; nixswitch; popd";
              rm = "echo -e \"\\e[01;31m Don't use rm. Use 'trash' instead. Or use full path '/bin/rm' \\e[0m\" 2&>"; # Correcting bad habits
              cp = "cp -i"; # Confirm before overwriting something
              df = "df -h"; # Human-readable sizes
              free = "free -m"; # Show sizes in MB
              open = "xdg-open";
              grepjs = "grep --include=\\*.{js,ts,tsx} --exclude-dir=node_modules -rEn";
              hist = "cat ~/.zsh_history | grep";
              cat = "bat";
              g = "git";
              z = "zellij";
              gcob = "git branch | fzf | xargs git checkout";
            };
            plugins = [ ];
            initExtra = ''
              '' + (builtins.readFile ./modules/home-manager/zsh-init-extra.zsh);
            envExtra = ''
              '';
          };

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

          programs.lazygit = {
            enable = true;
          };

          programs.zellij = {
            enable = true;
            enableZshIntegration = true;
            settings = {
              themes = {
                "everforest-dark" = {
                  bg = "#2b3339";
                  fg = "#d3c6aa";
                  black = "#4b565c";
                  red = "#e67e80";
                  green = "#a7c080";
                  yellow = "#dbbc7f";
                  blue = "#7fbbb3";
                  magenta = "#d699b6";
                  cyan = "#83c092";
                  white = "#d3c6aa";
                  orange = "#FF9E64";
                };
              };
              theme = "everforest-dark";
              pane_frames = false;
            };
          };

          programs.alacritty = {
            enable = true;
            settings =
              if pkgs.stdenv.isDarwin then {
                font.normal.family = "MesloLGS Nerd Font Mono";
                font.size = 16;
                window.option_as_alt = "OnlyLeft";
              } else {
                font.size = 13;
              };
            package =
              if pkgs.stdenv.isDarwin then
                pkgs.alacritty
              else (nixGLWrap pkgs.alacritty);
          };


          home.file.".inputrc".source = ./modules/home-manager/dotfiles/inputrc;

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

        };
      };
    };
}


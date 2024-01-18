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
      username = "diegodorado";
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      nixgl = import inputs.nixgl { pkgs = pkgs; };
      nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
        mkdir $out
        ln -s ${pkg}/* $out
        rm $out/bin
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
        legacyPackages.homeConfigurations.${username} =
          self.nixos-flake.lib.mkHomeConfiguration
            pkgs
            ({ pkgs, ... }: {
              imports = [ self.homeModules.default ];
              home.username = username;
              home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";
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
              home-manager.users.${username} = {
                imports = [ self.homeModules.default ];
                home.stateVersion = "22.11";
              };
            }
          ];
        };

        # home-manager configuration goes here.
        homeModules.default = { config, pkgs, ... }: {
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
            jq
            just
            go
            nushell
            lazygit
            htop
            heroku
            gh

            trash-cli
            slides

            # # It is sometimes useful to fine-tune packages, for example, by applying
            # # overrides. You can do that directly here, just don't forget the
            # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
            # # fonts?
            # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

            # # You can also create simple shell scripts directly inside your
            # # configuration. For example, this adds a command 'my-hello' to your
            # # environment:
            #(pkgs.writeShellScriptBin "my-hello" ''
              #echo "Hello, ${config.home.username}!"
            #'')
            (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./modules/home-manager/tmux-sessionizer))
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
          };

          programs.neovim= {
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            defaultEditor = true;
          };

          # simple approach: symlink nvim to this repository
          home.file."./.config/lnvim/" = {
            source = config.lib.file.mkOutOfStoreSymlink  "${config.home.homeDirectory}/Code/nix-config/lnvim";
          };
          home.file."./.config/nvim/" = {
            source = config.lib.file.mkOutOfStoreSymlink  "${config.home.homeDirectory}/Code/nix-config/nvim";
          };

            
          programs.bat.enable = true;
          programs.bat.config.theme = "TwoDark";
          programs.fzf.enable = true;
          programs.fzf.enableZshIntegration = true;

          programs.gpg.enable = true;
          home.file.".ssh/allowed_signers".text = '' 
          * ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChzNl+06IY+jUmgvD1Pp8cav1cAO6U0ml2FCSm9X5p6age0EqvYdcZOA8DjoP605arSEjT+kw1ncbqW58lNbssxozxlt2O/KyTVVNjtnogpSgaxXnwdBi/kYX1tqfiilaX2D/BVoAhRuSEUu73otbv8roSIfbio3lHegbjKWGdplVV7dxT307AHz8n0GZLGU+nO6bGynALAdjfEp1TCTmsTJ22A8YdztxtVkYNO+f5koNyEliIZT/arXr2KdvpN7+IUIR6mOsBuQ1/zt5c65y+fEllvMtZ6PmpjRuCansei8gyqYHbGcD2uJqu5wIsADw+T04/ikm7Fa4mOuN1+0Sihe13dUCXlPd6vCrHwF1MMUlNs9O9u6ImI/ejQ8Q9iWvHyNM7b1ZeT0aALGCZ08OuyuP6g5mUF1dT9/vrCYf2xjHCSAbxPg0B8ZODSp2j6UOUfMFsHJy+AHrj5u5QPxMr8/F7f/79N8RJK71kH8AiVwEWT9G0KOKQleFRl/alu3n/rH1I19lD9KBj82UUZxkMCPnbILEv4Ay2ELiPZ+8uPZsvvm7RbjEtCRC/D2XhxluGz1HFJ6nLxH3OWIXM8W0UKNMIlwR+tA1b83vY8LRhnF8GelzgTeakbCVcv5SDIbG/umfF82Pi+xOvplyG9WXCO2WSiinBNNh/14fFQN2CcQ== diegodorado@gmail.com
          * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBOIPunUINNvAF+xTstCiWgH82iUBrkfzc8USXJaibu diegodorado@gmail.com
          '';

          programs.git = {
            enable = true;
            userEmail = "diegodorado@gmail.com";
            userName = "Diego Dorado";
            aliases = {
              s = "status";
              co = "checkout";
              cp = "cherry-pick";
              fix = "v $(git diff --name-only --relative --diff-filter=U | uniq)";
              cm = "commit";
              rb= "rebase";
              rs= "restore";
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
              tag.gpgSign = false;
              core.editor = "vim";
              push.default = "simple";
              push.autoSetupRemote = true;
              gui.spellingdictionary = "none";
              gpg.format = "ssh";
              gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
              url."ssh://git@github.com/".insteadOf = "https://github.com/";
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
              hm = "pushd ~/Code/nix-config; nix run .#activate-home; popd; zsh";
              nixswitch = "darwin-rebuild switch --flake ~/Code/nix-config/.#";
              nixup = "pushd ~/Code/nix-config; nix flake update; nixswitch; popd";
              rm = "echo -e \"\\e[01;31m Don't use rm. Use 'trash' instead. Or use full path '/bin/rm' \\e[0m\" 2&>"; # Correcting bad habits
              cp = "${if pkgs.stdenv.isDarwin then "/bin/cp" else "cp" } -i"; # Confirm before overwriting something
              df = "df -h"; # Human-readable sizes
              free = "free -m"; # Show sizes in MB
              open = "xdg-open";
              grepjs = "grep --include=\\*.{js,ts,tsx} --exclude-dir=node_modules -rEn";
              cat = "bat";
              g = "git";
              lv = "NVIM_APPNAME=lnvim nvim"; # legacy lazyvim
              v = "nvim";
              # `t` to open tmux, `tt` to open a certain tmux session
              t = "TERM=tmux-256color tmux";
              tt = "tmux-sessionizer";
              gcob = "git branch | fzf | xargs git checkout";
            };
            plugins = [ ];
            initExtra = ''
              '' + (builtins.readFile ./modules/home-manager/zsh-init-extra.zsh);
            envExtra = ''
              '';
          };

          programs.tmux = {
            enable = true;
            sensibleOnTop = true;
            terminal = "tmux-256color";
            historyLimit = 99999;
            keyMode = "vi";
            mouse = true;
            shortcut = "s";
            baseIndex = 1;
            escapeTime = 0;
            disableConfirmationPrompt = true;
            clock24 = true;
            plugins = with pkgs.tmuxPlugins; [
              nord
              # fingers
              # online-status
              net-speed
              vim-tmux-navigator
              tmux-thumbs
              open
            ];
            extraConfig = ''
            # reload config
            bind r source-file ~/.config/tmux/tmux.conf \; display-message "config reloaded"

            # split windows
            bind '-' "split-window -v -c '#{pane_current_path}'"
            bind '\' "split-window -h -c '#{pane_current_path}'"

            # resize panes
            bind -r h resize-pane -L 2
            bind -r j resize-pane -D 1
            bind -r k resize-pane -U 1
            bind -r l resize-pane -R 2
            # resize panes faster
            bind -r H resize-pane -L 10
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 10

            # sessions
            bind -r s display-popup -E 'tmux-sessionizer'
            # switch back to previous session on detach
            set-option -g detach-on-destroy off

            # thumbs copy to clipboard, not to buffer
            # set -g @thumbs-command 'echo -n {} | pbcopy'

            '';
          };

          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
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

          programs.alacritty = {
            enable = true;
            settings =
              (if pkgs.stdenv.isDarwin then {
                font.normal.family = "MesloLGS Nerd Font Mono";
                font.size = 16;
              } else {
                font.size = 13;
              }) // {
                window = {
                  option_as_alt = "OnlyLeft";
                  opacity = 0.9;
                  decorations = "none";
                  startup_mode = "Maximized";
                };
                env = {
                  TERM = "xterm-256color";
                };
              };
            package =
              if pkgs.stdenv.isDarwin then
                pkgs.alacritty
              else (nixGLWrap pkgs.alacritty);
          };

          home.file.".inputrc".source = ./modules/home-manager/dotfiles/inputrc;

          # Let Home Manager install and manage itself.
          # programs.home-manager.enable = true;

        };
      };
    };
}


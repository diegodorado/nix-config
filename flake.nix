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
      stateVersion = "22.11";
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      nixgl = import inputs.nixgl { pkgs = pkgs; };
      nixGLWrap = pkg: pkgs.stdenv.mkDerivation {

        name = "${pkg.name}-nixgl-wrapper";
        version = pkg.version;
        src = pkgs.lib.cleanSource pkg;
        buildInputs = [ pkg ];

        installPhase = ''
          mkdir $out
          ln -s ${pkg}/* $out
          rm $out/bin
          mkdir $out/bin
          for bin in ${pkg}/bin/*; do
            wrapped_bin=$out/bin/$(basename $bin)
            echo "exec ${pkgs.lib.getExe nixgl.nixGLIntel} $bin \$@" >> $wrapped_bin
            chmod +x $wrapped_bin
          done
        '';

      };

    in

    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [ inputs.nixos-flake.flakeModule ];

      perSystem = { pkgs, ... }: {
        legacyPackages.homeConfigurations.${username} =
          self.nixos-flake.lib.mkHomeConfiguration
            pkgs
            ({ pkgs, ... }: {
              imports = [ self.homeModules.default ];
              home.username = username;
              home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";
              home.stateVersion = stateVersion;
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
                home.stateVersion = stateVersion;
              };
            }
          ];
        };

        # home-manager configuration goes here.
        homeModules.default = { config, pkgs, ... }: {
          imports = [
            ./home/programs/atuin.nix
            ./home/programs/git.nix
            ./home/programs/lazygit.nix
            ./home/programs/neovim.nix
            ./home/programs/password-store.nix
            ./home/programs/starship.nix
            ./home/programs/yazi.nix
            ./home/programs/zsh.nix
          ];

          # HACK: if binary is missing under tofi, delete .cache/tofi*
          # xdg.enable = true;
          # xdg.mime.enable = true;
          # xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
          # targets.genericLinux.enable = true;
          # export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"

          # This value determines the Home Manager release that your configuration is
          # compatible with. This helps avoid breakage when a new Home Manager release
          # introduces backwards incompatible changes.
          #
          # You should not change this value, even if you update Home Manager. If you do
          # want to update the value, then make sure to first check the Home Manager
          # release notes.
          home.stateVersion = stateVersion; # Please read the comment before changing.

          fonts.fontconfig.enable = true;
          # The home.packages option allows you to install Nix packages into your
          # environment.
          home.packages = with pkgs; (if pkgs.stdenv.isDarwin then [
            # darwin only packages
          ] else [
            # linux only packages
            calibre # e-book manager
            (pkgs.writeShellScriptBin "wob-wrapper" (builtins.readFile ./modules/home-manager/wob-wrapper))
          ]) ++ (
            import ./home/packages/shared.nix { pkgs = pkgs; }
          ) ++ [

            # Connect to "the other" machine
            (pkgs.writeShellScriptBin "sshh" ''
              IP=$( ${if pkgs.stdenv.isDarwin then
                  "dns-sd -t 1 -Q diegodorado-gtr.local"
                else
                  "avahi-resolve -n -4 dd-m1.local"
                } | grep -o "192.*")
              ssh $IP
            '')

            (pkgs.writeShellScriptBin "add-otp" (builtins.readFile ./modules/home-manager/add-otp))
          ];

          # TODO: add these files to home.file
          # /usr/share/sway/scripts/waybar.sh
          # ~/.config/sway/config
          # ~/.config/swaylock/config
          # ~/.config/tofi/config
          # ~/.config/waybar/config.jsonc
          # ~/.config/waybar/style.css
          # ~/bin/otp

          # These are linux specific configurations
          home.file = (if pkgs.stdenv.isDarwin then { } else {
            # # symlink to the Nix store copy.

            ".config/mako/config".text = ''
              default-timeout=10000
              border-size=3
              width=400
              height=200
              padding=20
              margin=20
              font=JetBrainsMono Nerd Font Mono 16
              # Colors
              background-color=#1e1e2e
              text-color=#cdd6f4
              border-color=#b4befe
              progress-color=over #313244
              [urgency=high]
              border-color=#fab387
            '';

            ".config/wob.ini".text = ''
              anchor = top center
              margin = 20
              border_color = b4befe
              bar_color = b4befe
              background_color=1e1e2e
            '';
          }) // {
            # shared files
            ".inputrc".source = ./modules/home-manager/dotfiles/inputrc;

            # simple approach: symlink nvim to this repository
            "./.config/nvim/" = {
              source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/nix-config/nvim";
            };

            # same for wezterm, for hot reload config
            # extraConfig = builtins.readFile ./modules/home-manager/wezterm/wezterm.lua;
            "./.config/wezterm/" = {
              source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/nix-config/wezterm";

            };

            ".ssh/allowed_signers".text =
              if pkgs.stdenv.isDarwin then ''
                * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBOIPunUINNvAF+xTstCiWgH82iUBrkfzc8USXJaibu diegodorado@gmail.com
              '' else ''
                * ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChzNl+06IY+jUmgvD1Pp8cav1cAO6U0ml2FCSm9X5p6age0EqvYdcZOA8DjoP605arSEjT+kw1ncbqW58lNbssxozxlt2O/KyTVVNjtnogpSgaxXnwdBi/kYX1tqfiilaX2D/BVoAhRuSEUu73otbv8roSIfbio3lHegbjKWGdplVV7dxT307AHz8n0GZLGU+nO6bGynALAdjfEp1TCTmsTJ22A8YdztxtVkYNO+f5koNyEliIZT/arXr2KdvpN7+IUIR6mOsBuQ1/zt5c65y+fEllvMtZ6PmpjRuCansei8gyqYHbGcD2uJqu5wIsADw+T04/ikm7Fa4mOuN1+0Sihe13dUCXlPd6vCrHwF1MMUlNs9O9u6ImI/ejQ8Q9iWvHyNM7b1ZeT0aALGCZ08OuyuP6g5mUF1dT9/vrCYf2xjHCSAbxPg0B8ZODSp2j6UOUfMFsHJy+AHrj5u5QPxMr8/F7f/79N8RJK71kH8AiVwEWT9G0KOKQleFRl/alu3n/rH1I19lD9KBj82UUZxkMCPnbILEv4Ay2ELiPZ+8uPZsvvm7RbjEtCRC/D2XhxluGz1HFJ6nLxH3OWIXM8W0UKNMIlwR+tA1b83vY8LRhnF8GelzgTeakbCVcv5SDIbG/umfF82Pi+xOvplyG9WXCO2WSiinBNNh/14fFQN2CcQ== diegodorado@gmail.com
              '';
          };

          home.sessionVariables = {
            PAGER = "less -R";
            CLICOLOR = 1;
          };

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

          programs.wezterm = {
            enable = true;
            enableZshIntegration = true;
            package =
              if pkgs.stdenv.isDarwin then
                pkgs.wezterm
              else (nixGLWrap pkgs.wezterm);
          };
          # allow to symlink the config file
          xdg.configFile."wezterm/wezterm.lua".enable = false;

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

        };
      };
    };
}


{
  description = "minimal flake";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs =
    inputs @ { nixpkgs
    , home-manager
    , darwin
    , ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
    in
    {
      darwinConfigurations.dd-m1 = darwin.lib.darwinSystem {
        inherit system;
        inherit pkgs;
        modules = [
          ./modules/darwin
        ];
      };


      homeConfigurations.diegodorado = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { };

        modules = [
          ./modules/home-manager
        ];
      };
    };
}

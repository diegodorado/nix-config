{ config, lib, pkgs, ... }:

let
  rustPlatform = pkgs.rustPlatform;
  rmpc = rustPlatform.buildRustPackage rec {
    pname = "rmpc";
    version = "0.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "mierak";
      repo = "rmpc";
      rev = "f9860973293a21ffd837e2a83a25ed3b38863f01";
      hash = "sha256-GWivvhIhRNZz0dcB2Bjqr0coxDAIhRM7Yg5BQ5hK16g=";
    };

    buildInputs = lib.optionals pkgs.stdenv.isDarwin [
      pkgs.darwin.apple_sdk.frameworks.IOKit
    ];

    patches = [
      # filename as title if missing tag
      (pkgs.fetchpatch {
        url = "https://github.com/mierak/rmpc/commit/60d138864c4957e4ae3a2e14dad082f19cd599e2.patch";
        hash = "sha256-3tfK2jMXBxJLILk3xQtkPHl8F/wLG45sdmeEsLHjx04=";
      })
    ];

    cargoHash = "sha256-oAiSSj6h/SkI6SzqH8vZrxGIxFvT9M+AVKgXkhBLIqY=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.cmake
    ];

  };
in
{

  config = {
    home.packages = with pkgs; [
      rmpc
    ];

    xdg.configFile = {
      "rmpc/config.ron".text = (builtins.readFile ./config.ron);
      "rmpc/themes/default.ron".text = (builtins.readFile ./theme.ron);
    };

  };

}

{ config, lib, pkgs, ... }:

let
  rustPlatform = pkgs.rustPlatform;
  rmpc = rustPlatform.buildRustPackage rec {
    pname = "rmpc";
    version = "0.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "mierak";
      repo = "rmpc";
      rev = "master";
      hash = "sha256-GWivvhIhRNZz0dcB2Bjqr0coxDAIhRM7Yg5BQ5hK16g=";
    };

    cargoHash = "sha256-oAiSSj6h/SkI6SzqH8vZrxGIxFvT9M+AVKgXkhBLIqY=";

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.cmake
    ];

    meta = {
      changelog = "https://github.com/mierak/rmpc/releases/tag/${src.rev}";
      description = "TUI music player client for MPD with album art support via kitty image protocol";
      homepage = "https://mierak.github.io/rmpc/";
      license = lib.licenses.bsd3;
      longDescription = ''
        Rusty Music Player Client is a beautiful, modern and configurable terminal-based Music Player
        Daemon client. It was inspired by ncmpcpp and aims to provide an alternative with support for
        album art through kitty image protocol without any ugly hacks. It also features ranger/lf
        inspired browsing of songs and other goodies.
      '';
      maintainers = with lib.maintainers; [ donovanglover ];
      mainProgram = "rmpc";
    };

  };
in
{

  config = {
    home.packages = with pkgs; [
      rmpc
    ];

    xdg.configFile = { };

  };

}

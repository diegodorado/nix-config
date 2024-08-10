{ config, lib, pkgs, ... }:

let
  musicDirectory = "${config.home.homeDirectory}/Music";
  mpdDirectory = "${config.home.homeDirectory}/.mpd";
  mpdConfigFile =
    if pkgs.stdenv.isDarwin then "${mpdDirectory}/mpd.conf"
    else ".config/mpd/mpd.conf";
  mpdConfig = ''
    music_directory         "${musicDirectory}"
    playlist_directory      "${config.home.homeDirectory}/.config/mpd/playlists"
  '' + (
    if pkgs.stdenv.isDarwin then ''
      # playlist_directory  "${mpdDirectory}/playlists"
      log_file            "${mpdDirectory}/log"
      db_file             "${mpdDirectory}/db"
      state_file          "${mpdDirectory}/state"
      pid_file            "${mpdDirectory}/pid"
      zeroconf_enabled    "no"
      audio_output {
        type "osx"
        name "CoreAudio"
      }
    '' else ''
    ''
  )
  ;

  mpcBinary = "${pkgs.mpc-cli}/bin/mpc";

  mpcWrapper = ''
    #!/bin/bash

    # Start mpd if not running
    if ! pgrep -x "mpd" > /dev/null; then
      mpd --no-daemon &
      sleep 2  # Wait for mpd to start up
    fi

    # Handle mpc commands
    if [ "$1" = "add" ] || [ "$1" = "insert" ]; then
      ABSOLUTE_PATH=$(realpath "$2")

      # Remove music directory path if present using sed
      RELATIVE_PATH=$(echo "$ABSOLUTE_PATH" | sed "s|^${musicDirectory}/||")

      # Pass command to mpc
      exec ${mpcBinary} "$1" "$RELATIVE_PATH"
    else
      exec ${mpcBinary} "$@"
    fi
  '';

  # Define a custom wrapper for mpc-cli
  mpc = pkgs.writeShellScriptBin "mpc" mpcWrapper;

in
{
  config = {

    home.packages = with pkgs; [
      mpd
      mus
      mpc
    ];

    services.mpd = {
      enable = true;
    };

    home.file = {
      "${mpdConfigFile}".text = mpdConfig;
    };
  };
}


{ config, lib, pkgs, ... }:

let
  musicDirectory = "${config.home.homeDirectory}/Music";
  mpdConfig = ''
    music_directory         "${musicDirectory}"
    playlist_directory      "${config.home.homeDirectory}/.config/mpd/playlists"
  '';

  mpcBinary = "${pkgs.mpc-cli}/bin/mpc";

  mpcWrapper = ''
    #!/bin/bash

    # Start mpd if not running
    if ! pgrep -x "mpd" > /dev/null; then
      mpd &
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

    xdg.configFile = {
      "mpd/mpd.conf".text = mpdConfig;
    };
  };
}


{ config, lib, pkgs, ... }:

let
  musicDirectory = "${config.home.homeDirectory}/Music";
  mpdConfig = ''
    music_directory         "${musicDirectory}"
    playlist_directory      "${config.home.homeDirectory}/.config/mpd/playlists"
  '';

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
      exec mpc "$1" "$RELATIVE_PATH"
    else
      exec mpc "$@"
    fi
  '';


in
{

  config = {

    # add required packages and flavors/plugins configurations
    home.packages = with pkgs; [
      mpd
      mus
      mpc-cli
      (writeShellScriptBin "mpcw" mpcWrapper)
    ];

    xdg.configFile = {
      "mpd/mpd.conf".text = mpdConfig;
    };

  };

}


{ config, lib, pkgs, ... }:

let
  name = "mpd";
  dataDir = "${config.xdg.dataHome}/${name}";
  musicDirectory = "${config.home.homeDirectory}/Music";
  playlistDir = "${dataDir}/playlists";

  mpdConf = pkgs.writeText "mpd.conf" (''
    bind_to_address "/tmp/mpd_socket"
    music_directory     "${musicDirectory}"
    playlist_directory  "${playlistDir}"
    log_file            "${dataDir}/log"
    db_file             "${dataDir}/db"
    metadata_to_use     "artist,album,title,date"
    state_file          "${dataDir}/state"
    pid_file            "${dataDir}/pid"
  '' + (
    if pkgs.stdenv.isDarwin then ''
      zeroconf_enabled    "no"
      audio_output {
        type "osx"
        name "CoreAudio"
      }
    '' else ''
    ''
  ));

  # redefine mpd
  mpd = pkgs.writeShellScriptBin "mpd" ''
    mkdir -p ${dataDir} ${playlistDir}
    ${pkgs.mpd}/bin/mpd --no-daemon ${mpdConf}
  '';

  # redefine mpc
  mpc = pkgs.writeShellScriptBin "mpc" ''
    # Start mpd if not running
    if ! pgrep -x "mpd" > /dev/null; then
      mpd &
      sleep 2  # Wait for mpd to start up
    fi

    # Handle mpc commands
    if [ "$1" = "add" ] || [ "$1" = "insert" ]; then
      ABSOLUTE_PATH=$(realpath "$2")

      # Check if the ABSOLUTE_PATH starts with the musicDirectory
      if [[ "$ABSOLUTE_PATH" == "${musicDirectory}/"* ]]; then
        # Remove music directory path if present using sed
        RELATIVE_PATH=$(echo "$ABSOLUTE_PATH" | sed "s|^${musicDirectory}/||")

        # Redefine positional parameters
        set -- "$1" "$RELATIVE_PATH"
      fi

    fi
    exec ${pkgs.mpc-cli}/bin/mpc "$@"
  '';

in
{
  config = {

    home.packages = with pkgs; [
      mpd
      mus
      mpc
    ];

  };
}


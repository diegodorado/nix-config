{ pkgs, ... }:

with pkgs; [
  nix # fucking nix itself

  curl
  tldr
  fd
  fzf
  less
  ripgrep
  jq
  just
  go
  htop
  heroku
  gh
  direnv

  act # run your github actions locally

  autossh # autorestart ssh sessions and tunnels
  shfmt # shell script formatter

  uv # python package manager
  fx # json/yaml browser

  scc # code counter with complexity calculations
  duf # disk usage/free utility
  bandwhich # display current network utilization
  dua # disk usage analyzer

  browsh # modern text-based browser
  asciinema # terminal session recorder 

  yt-dlp # download youtube videos

  lsix # ls for images
  hexyl # hex viewer

  netcat-gnu # read/write data over network
  socat # data transfer between data channels

  texliveMedium # pdfcrop, among other things

  # cpp build tools
  build2
  bdep

  cc65 # C compiler for processors of 6502 family

  ols # odin language server

  # zig
  # vice # Versatile Commodore Emulator
  scrcpy # Display and control Android devices over USB or TCP/IP

  liblo # oscsend/dump

  trash-cli

  slides # markdown presentation in the terminal
  glow # render markdown in the terminal

  sox
  ffmpeg
  mkvtoolnix # cross-platform tools for matroska

  wormhole-william
  swift-format

  maestro # mobile automation tool

  leiningen
  clojure

  # large language models
  ollama

  odin # The Data-Oriented Language for Sane Software Development.

  nerd-fonts.jetbrains-mono

]

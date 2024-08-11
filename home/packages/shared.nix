{ pkgs, ... }:

with pkgs; [
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

  lsix # ls for images
  hexyl # hex viewer

  netcat-gnu # read/write data over network
  socat # data transfer between data channels

  # cpp build tools
  build2
  bdep

  cointop

  liblo # oscsend/dump

  trash-cli

  slides # markdown presentation in the terminal
  glow # render markdown in the terminal

  sox
  ffmpeg

  wormhole-william
  swift-format

  maestro # mobile automation tool

  leiningen
  clojure

  # large language models
  # ollama

  # # It is sometimes useful to fine-tune packages, for example, by applying
  # # overrides. You can do that directly here, just don't forget the
  # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  # # fonts?
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })


]

{ config, pkgs, lib, ... }:

{

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p;[
        asm
        bash
        c
        cpp
        go
        haskell
        java
        javascript
        lua
        nix
        # openscad ...not included yet..
        odin
        python
        ruby
        rust
        ron
        supercollider
        swift
        tsx
        typescript
        vim
        vimdoc
        yaml
        zig
      ]))
    ];
  };



}

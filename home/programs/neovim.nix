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
      ]))
    ];
  };



}

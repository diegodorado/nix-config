{ config, pkgs, lib, ... }:

{

  programs.lazygit = {
    enable = true;
    settings = {
      git.overrideGpg = true;
      quitOnTopLevelReturn = true;
      gui.skipDiscardChangeWarning = true;
      gui.mouseEvents = false;
      gui.showCommandLog = false;
      gui.showBottomLine = false;
      gui.showPanelJumps = false;
      keybinding.universal.toggleWhitespaceInDiffView = "";
      keybinding.universal.togglePanel = "<c-w>";
    };
  };


}

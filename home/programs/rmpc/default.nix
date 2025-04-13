{ config, lib, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      rmpc
    ];

    xdg.configFile = {
      "rmpc/config.ron".text = (builtins.readFile ./config.ron);
      "rmpc/themes/default.ron".text = (builtins.readFile ./theme.ron);
    };

  };

}

{ config, pkgs, lib, ... }:

let
  passwordStoreDir = "${config.home.homeDirectory}/.password-store";
  addOtp = builtins.readFile ./add-otp;
  copyOtpTemplate = builtins.readFile ./copy-otp;
  copyOtp = builtins.replaceStrings [ "$PASSWORD_STORE_DIR" ] [ passwordStoreDir ] copyOtpTemplate;
in
{

  home.packages = with pkgs; [
    zbar # bar code reader
    qrencode # encode to a qr code symbol
    (writeShellScriptBin "add-otp" addOtp)
    (writeShellScriptBin "copy-otp" copyOtp)
  ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = passwordStoreDir;
    };
  };



}

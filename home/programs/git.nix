{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "diegodorado@gmail.com";
    userName = "Diego Dorado";
    aliases = {
      s = "status";
      co = "checkout";
      cp = "cherry-pick";
      fix = "!sh -c 'nvim \$(git diff --name-only --relative --diff-filter=U | uniq)'";
      pr = "!sh -c 'GH_FORCE_TTY=100% gh pr list --limit 300 | grep -E \"#[0-9]+\" | fzf --ansi --preview \"GH_FORCE_TTY=100% gh pr view {1}\" --preview-window down,70% --header-lines 3 | sed \"s/.*#\\([0-9]\\+\\).*/\\1/\" | xargs --no-run-if-empty  gh pr checkout'";
      cm = "commit";
      rb = "rebase";
      rs = "restore";
      cma = "commit --amend";
      pf = "push --force-with-lease";
      ll = "log --oneline";
    };
    delta = {
      enable = true;
      options = {
        syntax-theme = "base16-256";
        navigate = true;
        features = "line-numbers decorations";
        plus-style = ''syntax "#003f01"'';
        minus-style = ''syntax "#3f0001"'';
      };
    };
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_${if pkgs.stdenv.isDarwin then "ed25519" else "rsa" }.pub";
    };
    extraConfig = {
      tag.gpgSign = true;
      core.editor = "vim";
      push.default = "simple";
      push.autoSetupRemote = true;
      gui.spellingdictionary = "none";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      init.defaultBranch = "main";
    };
  };
}

{ config, lib, ... }:

with lib;

let
  cfg = config.modules.git;
in {
  options.modules.git = {
    enable = mkEnableOption "enable git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      aliases = {
        # From https://stackoverflow.com/a/5188364
        list-branches = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
      };
      ignores = [ ".*.sw*" "*.o" "*.ko" "*.pyc" ];
      extraConfig = {
        core = {
          editor = "vim";
        };
        merge = {
          renamelimit = 65535;
          ff = "only";
        };
        pull.ff = "only";
        rerere.enabled = "true";
        am.threeWay = true;
        init.defaultBranch = "main";
      };
    };

    programs.zsh.shellAliases = {
      gdc = "git describe --contains";
      grm = "git commit --reuse-message=HEAD@{1}";
    };
  };
}

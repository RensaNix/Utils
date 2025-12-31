{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) pkgs devshell treefmt devtools-lib;
  inherit (cell) soonix;
  treefmtWrapper = treefmt.mkWrapper pkgs {
    programs = {
      alejandra.enable = true;
      statix.enable = true;
      deadnix.enable = true;
      mdformat.enable = true;
    };
  };
in {
  default = devshell.mkShell {
    imports = [soonix.devshellModule devtools-lib.devshellModule];
    packages = [
      pkgs.nil
      treefmtWrapper
    ];
    lefthook.config = {
      "pre-commit" = {
        parallel = true;
        jobs = [
          {
            name = "treefmt";
            stage_fixed = true;
            run = "${treefmtWrapper}/bin/treefmt";
            env.TERM = "dumb";
          }
          {
            name = "soonix";
            stage_fixed = true;
            run = "${soonix.packages."soonix:update"}/bin/soonix:update";
          }
        ];
      };
    };
    cocogitto.config = {
      tag_prefix = "v";
      ignore_merge_commits = true;
      changelog = {
        authors = [
          {
            username = "TECHNOFAB";
            signature = "technofab";
          }
        ];
        path = "CHANGELOG.md";
        template = "remote";
        remote = "gitlab.com";
        repository = "utils";
        owner = "rensa-nix";
      };
    };
  };
}

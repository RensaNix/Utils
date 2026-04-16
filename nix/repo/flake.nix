{
  inputs = {
    nixmkdocs.url = "gitlab:TECHNOFAB/nixmkdocs/v1.1.0?dir=lib";
    devshell.url = "gitlab:rensa-nix/devshell/v0.1.0?dir=lib";
    devtools-lib.url = "gitlab:rensa-nix/devtools/v0.1.0?dir=lib";
    soonix-lib.url = "gitlab:TECHNOFAB/soonix/v0.2.0?dir=lib";
    nix-gitlab-ci-lib.url = "gitlab:TECHNOFAB/nix-gitlab-ci/3.1.2?dir=lib";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      flake = false;
    };
  };
  outputs = i:
    i
    // {
      doclib = i.nixmkdocs.lib {inherit (i.parent) pkgs;};
      devshell = i.devshell.lib {inherit (i.parent) pkgs;};
      soonix = i.soonix-lib.lib {inherit (i.parent) pkgs;};
      cilib = i.nix-gitlab-ci-lib.lib {inherit (i.parent) pkgs;};
      utils = import "${i.parent.self}/lib" {inherit (i.parent.pkgs) lib;};
      treefmt = import i.treefmt-nix;
    };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ren.url = "gitlab:rensa-nix/core/v0.2.0?dir=lib";
  };

  outputs = {
    ren,
    self,
    ...
  } @ inputs:
    ren.buildWith
    {
      inherit inputs;
      cellsFrom = ./nix;
      transformInputs = system: i:
        i
        // {
          pkgs = import i.nixpkgs {inherit system;};
        };
    }
    {
      packages = ren.select self [
        ["repo" "docs"]
        ["repo" "ci" "packages"]
        ["repo" "soonix" "packages"]
      ];
    };
}

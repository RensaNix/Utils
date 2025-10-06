{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) pkgs devshell treefmt soonix;
  inherit (cell) ci;
in {
  default = devshell.mkShell {
    imports = [soonix.devshellModule];
    packages = [
      pkgs.nil
      (treefmt.mkWrapper pkgs {
        programs = {
          alejandra.enable = true;
          statix.enable = true;
          deadnix.enable = true;
          mdformat.enable = true;
        };
      })
    ];
    soonix.hooks.ci = ci.soonix;
  };
}

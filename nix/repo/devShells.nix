{inputs, ...}: let
  inherit (inputs) pkgs devshell treefmt;
in {
  default = devshell.mkShell {
    packages = [
      pkgs.nil
      (treefmt.mkWrapper pkgs {
        programs = {
          alejandra.enable = true;
          deadnix.enable = true;
          mdformat.enable = true;
        };
      })
    ];
  };
}

{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkOptionType types isAttrs hasAttr;
  mkInputOption = description:
    mkOption {
      type = mkOptionType {
        name = "input";
        description = "a flake input";
        check = x: (isAttrs x) && (hasAttr "sourceInfo" x);
      };
      description = ''
        The flake input for ${description}.

        Example:
          ren.home-manager = inputs.home-manager;
      '';
    };
in {
  options.ren = {
    system = mkOption {
      type = types.str;
      description = ''
        The system architecture (e.g., 'x86_64-linux', 'aarch64-darwin').
      '';
    };

    home-manager = mkInputOption "Home Manager";
    disko = mkInputOption "Disko";
    nixos-wsl = mkInputOption "NixOS-WSL";
    nix-darwin = mkInputOption "nix-darwin";

    pkgs = mkOption {
      type = mkOptionType {
        name = "packages";
        description = "instance of nixpkgs";
        check = x: (isAttrs x) && (hasAttr "path" x);
      };
      description = ''
        An instantiated nixpkgs set. Used for general pkgs and to get NixOS systems' modules.
      '';
      apply = x:
        if (hasAttr "${config.ren.system or "unset"}" x)
        then x.${config.ren.system}
        else x;
    };
  };
}

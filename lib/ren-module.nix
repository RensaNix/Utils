{
  lib,
  config,
  options,
  ...
}: let
  inherit (lib) mkOption mkOptionType types isAttrs hasAttr literalExpression;
  mkInputOption = name: description:
    mkOption {
      type = mkOptionType {
        name = "input";
        description = "flake input for ${name}";
        check = x: (isAttrs x) && (hasAttr "sourceInfo" x);
      };
      description = ''
        The flake input for ${description}.
      '';
      example = literalExpression "inputs.${name}";
    };
in {
  options.ren = {
    system = mkOption {
      type = types.str;
      description = ''
        The system architecture (e.g., `x86_64-linux`, `aarch64-darwin`).
      '';
      default =
        if options.ren.pkgs.isDefined
        then config.ren.pkgs.system
        else "";
      defaultText = literalExpression ''
        if options.ren.pkgs.isDefined then config.ren.pkgs.system else "";
      '';
    };

    home-manager = mkInputOption "home-manager" "Home Manager";
    disko = mkInputOption "disko" "Disko";
    nixos-wsl = mkInputOption "nixos-wsl" "NixOS-WSL";
    nix-darwin = mkInputOption "nix-darwin" "nix-darwin";

    pkgs = mkOption {
      type = mkOptionType {
        name = "packages";
        description = "instance of nixpkgs";
        check = x: (isAttrs x) && (hasAttr "path" x);
      };
      description = ''
        An instantiated nixpkgs set. Used for general pkgs and to get NixOS systems' modules.
      '';
      example = literalExpression ''
        import inputs.nixpkgs { system = "aarch64-linux"; };
      '';
    };
  };
}

{lib}: userConfig: let
  inherit (lib) evalModules types assertMsg isAttrs optionals mkDefault;

  evaled = evalModules {
    modules = [
      ./ren-module.nix
      userConfig
      {
        config._module.check = true;
        config._module.freeformType = types.unspecified;
      }
    ];
  };

  isDarwin = evaled.options.ren.nix-darwin.isDefined;
  nix-darwin = assert assertMsg (isAttrs evaled.config.ren.nix-darwin) "nix-darwin input unset"; evaled.config.ren.nix-darwin;

  baseModules = [./ren-module.nix userConfig];

  nixosModules = import (evaled.config.ren.pkgs.path + "/nixos/modules/module-list.nix");
  darwinModules = import (evaled.config.ren.nix-darwin + "/modules/module-list.nix");

  extraNixosConfig = {
    nixpkgs = {
      inherit (evaled.config.ren) system pkgs;
    };
    imports =
      # add home-manager if the input is passed
      optionals evaled.options.ren.home-manager.isDefined [
        evaled.config.ren.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = mkDefault true;
          home-manager.useUserPackages = mkDefault false;
        }
      ]
      # add nixos-wsl if the input is passed
      ++ optionals evaled.options.ren.nixos-wsl.isDefined [
        evaled.config.ren.nixos-wsl.nixosModules.wsl
        {
          wsl.enable = mkDefault true;
        }
      ]
      # add disko if the input is passed
      ++ optionals evaled.options.ren.disko.isDefined [
        evaled.config.ren.disko.nixosModules.disko
      ];
  };
  extraDarwinConfig = {
    # add home-manager if the input is passed
    imports = optionals evaled.options.ren.home-manager.isDefined [
      evaled.config.ren.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = mkDefault true;
        home-manager.useUserPackages = mkDefault false;
      }
    ];
  };

  systemConfig = import (evaled.config.ren.pkgs.path + "/nixos/lib/eval-config.nix") {
    system = null;
    modules = baseModules ++ [extraNixosConfig] ++ nixosModules;
  };
  darwinConfig = nix-darwin.lib.darwinSystem {
    inherit (evaled.config.ren) system pkgs;
    modules = baseModules ++ [extraDarwinConfig] ++ darwinModules;
  };
in
  (
    if isDarwin
    then darwinConfig
    else systemConfig
  )
  // {
    inherit userConfig;
    innerConfig = {
      imports = [userConfig ./ren-module.nix];
    };
  }

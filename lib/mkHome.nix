{lib}: userConfig: let
  inherit (lib) evalModules types assertMsg isAttrs toString;
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

  home-manager = assert assertMsg (isAttrs evaled.config.ren.home-manager) "home-manager input unset"; evaled.config.ren.home-manager;
  hmLib = import (home-manager + /modules/lib/stdlib-extended.nix) lib;
  hmModules = import (home-manager + /modules/modules.nix) {
    inherit (evaled.config.ren) pkgs;
    lib = hmLib;
    check = true;
    useNixpkgsModule = false;
  };

  homeConfig = hmLib.evalModules {
    specialArgs = {
      modulesPath = toString (evaled.config.bee.home + /modules);
    };
    modules = [./ren-module.nix userConfig] ++ hmModules;
  };
in {
  innerConfig = {
    imports = [userConfig ./ren-module.nix];
  };
  inherit (homeConfig) options config;
  inherit (homeConfig.config.home) activationPackage;
}

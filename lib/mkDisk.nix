{lib}: userConfig: let
  inherit (lib) evalModules types assertMsg isAttrs;

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

  disko = assert assertMsg (isAttrs evaled.config.ren.disko) "disko input unset"; evaled.config.ren.disko;
  diskoLib = import "${disko}/lib" {inherit lib;};

  diskConfig = evalModules {
    modules = [
      ./ren-module.nix
      userConfig
      {
        # required since its a type, not a module
        freeformType = diskoLib.toplevel;
      }
    ];
  };
in {
  innerConfig = builtins.removeAttrs diskConfig.config ["ren"];
  inherit (diskConfig) config options;
  scripts = diskConfig.config._scripts {inherit (evaled.config.ren) pkgs;};
}

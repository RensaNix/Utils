# Utility Functions

## `mkSystem :: attrs -> attrs` { #mkSystem }

Wraps a NixOS or `nix-darwin` configuration. Optionally integrates `nix-wsl` (NixOS only), `disko` (NixOS only) and/or `home-manager`.

If you want to integrate `disko`, just set `disko.devices` to `utils.collectDisks cell.disks` like below.

If you want to integrate `home-manager`, set the user's config in `home-manager.users.<username>` to the `innerConfig` output of [`mkHome`](#mkHome), like below.

**Example**:

```nix title="cells/host/nixos.nix"
{inputs, cell, ...}: let 
  inherit (inputs) utils;
in {
  test = utils.mkSystem {
    ren = {
      inherit (inputs) pkgs disko home-manager;
    };

    disko.devices = utils.collectDisks cell.disks;

    home-manager = {
      useUserPackages = false;
      useGlobalPkgs = true;
      users."demo" = cell.home."demo@test".innerConfig;
    };
    # also configure users etc.

    system.stateVersion = "25.11";
  };
}
```

**Exposes**:

- `userConfig`: the raw user-passed config
- `innerConfig`: config plus the `ren-module`
- `config`, `options`: nix module config and options passed through

## `mkHome :: attrs -> attrs` { #mkHome }

Wraps a home-manager configuration.

**Example**:

```nix title="cells/host/home.nix"
{inputs, ...}: let 
  inherit (inputs) utils;
in {
  "demo@test" = utils.mkHome {
    ren = {
      inherit (inputs) pkgs home-manager;
    };

    home = {
      stateVersion = "25.11";
      username = "demo";
      homeDirectory = "/home/demo";
    };
  };
}
```

**Exposes**:

- `userConfig`: the raw user-passed config
- `innerConfig`: config plus the `ren-module`
- `activationPackage`: alias for `config.home.activationPackage`
- `config`, `options`: nix module config and options passed through

## `mkDisk :: attrs -> attrs` { #mkDisk }

Wraps a single disko configuration. Exposes the disk's generated scripts etc.

**Example**:

```nix title="cells/host/disks/some_disk.nix"
{inputs, ...}: let 
  inherit (inputs) utils;
in utils.mkDisk {
  ren = {
    inherit (inputs) pkgs disko;
  };
  disk."whatever" = {
    device = "/device";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
          attributes = [0];
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
```

**Exposes**:

- `userConfig`: the raw user-passed config
- `innerConfig`: config without `ren` config attributes
- `scripts`: the disks scripts, for mounting, formatting etc.
- `config`, `options`: nix module config and options passed through

## `collectDisks :: attrs -> attrs` { #collectDisks }

Collects all disks from the cell, can be passed to `#!nix disko.devices`.

**Example**:

```nix
disko.devices = utils.collectDisks cell.disks;
```

**Arguments**:

- `disks`: all disks from the current cell for example

## `findModules :: {dir, currentFile, relative} -> [files]` { #findModules }

Find modules/files in directory, return them all as a list of paths to import.

**Arguments**

- `dir`: directory to search in
- `currentFile`: file to exclude (default: `#!nix "default.nix"`)
- `relative`: whether to return relative paths (default: `#!nix false`)

## `importModules :: {dir, args, currentFile, usePathAsKeys} -> attrs` { #importModules }

Find, then import, then merge all modules in a dir.

**Arguments**

- `dir`: directory to search in
- `args`: arguments to pass to the imported modules (default: `#!nix {}`)
- `currentFile`: file to exclude (default: `#!nix "default.nix"`)
- `usePathAsKeys`: whether to nest the values by their path (default: `#!nix false`)

{lib, ...} @ args: let
  inherit
    (lib)
    pipe
    mapAttrs
    flatten
    hasSuffix
    removeSuffix
    removePrefix
    splitString
    setAttrByPath
    foldr
    recursiveUpdate
    ;
in rec {
  module = ./ren-module.nix;

  mkSystem = import ./mkSystem.nix args;
  mkHome = import ./mkHome.nix args;
  mkDisk = import ./mkDisk.nix args;

  # collects all disks from the cell, can be passed to disko.devices:
  #
  #   disko.devices = utils.collectDisks cell.disks;
  collectDisks = disks:
    foldr (acc: item: recursiveUpdate acc item) {}
    (map (dev: builtins.removeAttrs dev.userConfig ["ren"])
      (builtins.attrValues disks));

  # find modules/files in directory, return them all as a list of paths to import
  findModules = {
    dir,
    currentFile ? "default.nix",
    relative ? false,
  }: let
    processDir = subDir: first:
      pipe "${dir}${subDir}" [
        builtins.readDir
        (mapAttrs (
          n: v: let
            p =
              if relative
              then "${subDir}/${n}"
              else "${dir}${subDir}/${n}";
          in
            if v == "directory"
            then (processDir "${subDir}/${n}" false)
            else
              # filter out the current file to prevent recursive import
              if first && n == currentFile
              then []
              else p
        ))
        builtins.attrValues
        flatten
        (builtins.filter (path: hasSuffix ".nix" path))
      ];
  in
    processDir "" true;

  # find, then import, then merge all modules in a dir
  importModules = {
    dir,
    args ? {},
    currentFile ? "default.nix",
    usePathAsKeys ? false,
  }: let
    allNixFiles = findModules {
      inherit dir currentFile;
      relative = true;
    };

    filePathToAttrPath = filePath: let
      relativePath = removeSuffix ".nix" (removePrefix "/" filePath);
    in
      splitString "/" relativePath;

    importAndProcessFile = file: let
      importedData = import "${dir}/${file}" args;
      attrPath = filePathToAttrPath file;
    in
      if usePathAsKeys
      then setAttrByPath attrPath importedData
      else importedData;

    importedContents = map importAndProcessFile allNixFiles;
    mergedFiles = foldr (acc: item: recursiveUpdate acc item) {} importedContents;
  in
    mergedFiles;
}

{
  lib,
  mkTypstPackage,
  getTypstPackagePathsFromList,
}:
srcs:
let
  packageSetWithoutAbsolutePaths = builtins.mapAttrs (
    namespace: packageSrcs:
    builtins.foldl'
      (
        acc: src:
        let
          package = mkTypstPackage { inherit src namespace; };
          versionList = builtins.match "([0-9]+)\.([0-9]+)\.([0-9]+)" package.version;
          major = builtins.elemAt versionList 0;
          minor = builtins.elemAt versionList 1;
          patch = builtins.elemAt versionList 2;
        in
        attrsets.recursiveUpdate acc {
          "${package.name}:${package.version}" = package;
          ${package.name} = {
            ${package.version} = package;
            ${major}.${minor}.${patch} = package;
          };
        }
      )
      { }
      (
        getTypstPackagePathsFromList (
          builtins.map (src: if builtins.isAttrs src then getDerivationPackages src else src) packageSrcs
        )
      )
  ) srcs;

  attrsets = lib.attrsets;
  isDerivation = x: x ? "type" && x.type == "derivation";
  getDerivationPackages = attrsets.filterAttrs (name: value: isDerivation value);

  absolutePaths = attrsets.concatMapAttrs (
    namespace: packages:
    attrsets.concatMapAttrs (name: value: { "${namespace}/${name}" = value; }) (
      getDerivationPackages packages
    )
  ) packageSetWithoutAbsolutePaths;
in
packageSetWithoutAbsolutePaths // absolutePaths

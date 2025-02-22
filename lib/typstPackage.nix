{pkgs}: let
  lists = pkgs.lib.lists;
  attrsets = pkgs.lib.attrsets;
in rec {
  getTypstPackagePathsFromList = packages: lists.unique (lists.flatten (builtins.map getTypstPackagePaths packages));

  getTypstPackagePaths = dir: let
    contents = builtins.readDir dir;
    subdirs = builtins.filter (x: x != null) (attrsets.mapAttrsToList (key: value:
      if value == "directory" || value == "symlink"
      then key
      else null)
    contents);
  in
    if builtins.elem "typst.toml" (builtins.attrNames contents)
    then [dir]
    else lists.unique (lists.flatten (builtins.map (subdir: getTypstPackagePaths "${dir}/${subdir}") subdirs));

  mkTypstPackage = {
    src, # Path to a typst package. Expects 'typst.toml' at the top level.
    namespace ? "preview", # Name of the namespace the package should appear under.
    packages ? [], # Will include (symlinkJoin) into the same derevation.
    # fonts ? [], # TODO/figure out (with builtInputs or an extra attribute perhaps?)
  }: let
    package = pkgs.stdenvNoCC.mkDerivation rec {
      inherit ((builtins.fromTOML (builtins.readFile "${src}/typst.toml")).package) name version;

      dontUnpack = true;

      installPhase = ''
        mkdir --parents "$out/${namespace}/${name}"
        ln --symbolic "${src}" "$out/${namespace}/${name}/${version}"
      '';
    };
  in
    if packages != []
    then
      pkgs.symlinkJoin {
        inherit (package) name version;
        paths = packages ++ [package];
      }
    else package;

  mergeTypstPackages = packagesOrPackageSets: let
    isDerivation = x: x ? "type" && x.type == "derivation";
  in
    pkgs.symlinkJoin {
      name = "";
      paths = builtins.foldl' (acc: elem:
        acc
        ++ (
          if isDerivation elem
          then [elem]
          else attrsets.collect isDerivation elem
        )) []
      packagesOrPackageSets;
    };

  mkTypstPackageSet = srcs: let
    packageSetWithoutAbsolutePaths = builtins.mapAttrs (namespace: packageSrcs:
      builtins.foldl' (acc: src: let
        package = mkTypstPackage {inherit src namespace;};
        versionList = builtins.match "([0-9]+)\.([0-9]+)\.([0-9]+)" package.version;
        major = builtins.elemAt versionList 0;
        minor = builtins.elemAt versionList 1;
        patch = builtins.elemAt versionList 2;
      in
        attrsets.recursiveUpdate acc {
          ${package.name} = {
            ${package.version} = package;
            ${major}.${minor}.${patch} = package;
          };
        })
      {} (getTypstPackagePathsFromList packageSrcs))
    srcs;
  in
    packageSetWithoutAbsolutePaths
    // (
      builtins.foldl' (acc: packages: acc // packages) {} (builtins.attrValues (builtins.mapAttrs (
          namespace: packages: let
            packageDrvs = attrsets.collect (x: x ? "type" && x.type == "derivation") packages;
          in
            builtins.foldl' (acc: package: acc // {"${namespace}/${package.name}:${package.version}" = package;}) {} packageDrvs
        )
        packageSetWithoutAbsolutePaths))
    );
}

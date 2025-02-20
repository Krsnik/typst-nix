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
    src,
    namespace ? "preview",
    # packages ? [], # TODO: dependencies
    # fonts ? [],
  }:
    pkgs.stdenvNoCC.mkDerivation rec {
      inherit ((builtins.fromTOML (builtins.readFile "${src}/typst.toml")).package) name version;

      dontUnpack = true;

      installPhase = ''
        mkdir --parents "$out/${namespace}/${name}"
        ln --symbolic "${src}" "$out/${namespace}/${name}/${version}"
      '';
    };

  mergeTypstPackages = packageSets:
    pkgs.symlinkJoin {
      name = "";
      paths = packageSets;
    };

  mkTypstPackageSet = srcs:
    builtins.mapAttrs (namespace: packageSrcs:
      builtins.foldl' (acc: src: let
        package = mkTypstPackage {inherit src namespace;};
      in
        attrsets.recursiveUpdate acc {${package.name}.${package.version} = package;})
      {} (getTypstPackagePathsFromList packageSrcs))
    srcs;
}

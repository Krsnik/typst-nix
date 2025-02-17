{pkgs}: let
  lists = pkgs.lib.lists;
  attrsets = pkgs.lib.attrsets;
in rec {
  toTypstPackageList = packages: lists.flatten (builtins.map getTypstPackagePaths packages);

  getTypstPackagePaths = dir: let
    contents = builtins.readDir dir;
    subdirs = builtins.filter (x: x != null) (attrsets.mapAttrsToList (key: value:
      if value == "directory" || value == "symlink"
      then key
      else null)
    contents);
  in
    if (builtins.filter (x: x == "typst.toml") (builtins.attrNames contents)) == []
    then lists.flatten (builtins.map (subdir: getTypstPackagePaths "${dir}/${subdir}") subdirs)
    else [dir];

  mkTypstPackageSet = srcs:
    pkgs.stdenvNoCC.mkDerivation {
      name = "";

      dontUnpack = true;

      installPhase = ''
        mkdir $out

        ${
          builtins.toString (builtins.map (
              namespace:
                builtins.map (src: let
                  inherit ((builtins.fromTOML (builtins.readFile "${src}/typst.toml")).package) name version;
                in ''
                  mkdir -p $out/${namespace}/${name}
                  cp -r ${src} $out/${namespace}/${name}/${version}
                '')
                (toTypstPackageList srcs.${namespace})
            )
            (builtins.attrNames srcs))
        }
      '';
    };

  mkTypstPackage = {
    src,
    namespace ? "preview",
    # packages ? [], # TODO: dependencies
    # fonts ? [],
  }:
    mkTypstPackageSet {${namespace} = [src];};

  mergeTypstPackageSets = packageSets:
    pkgs.symlinkJoin {
      name = "";
      paths = packageSets;
    };
}

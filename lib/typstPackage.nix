{pkgs}: let
  strings = pkgs.lib.strings;
  lists = pkgs.lib.lists;
  attrsets = pkgs.lib.attrsets;
in rec {
  toPackageList = packages: lists.flatten (builtins.map getTypstPackagePaths packages);

  getTypstPackagePaths = dir: let
    contents = builtins.readDir dir;
    subdirs = builtins.filter (x: x != null) (attrsets.mapAttrsToList (key: value:
      if value == "directory"
      then key
      else null)
    contents);
  in
    if (builtins.filter (x: x == "typst.toml") (builtins.attrNames contents)) == []
    then lists.flatten (builtins.map (subdir: getTypstPackagePaths "${dir}/${subdir}") subdirs)
    else [dir];

  mkPackageSet = srcs:
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
                  ${
                    if name == "sigfig"
                    then "echo ${name} ${version} ${builtins.toString src}"
                    else ""
                  }
                  mkdir -p $out/${namespace}/${name}
                  cp -r ${src} $out/${namespace}/${name}/${version}
                '')
                srcs.${namespace}
            )
            (builtins.attrNames srcs))
        }
      '';
    };

  mkPackage = {
    src,
    namespace,
  }:
    mkPackageSet {${namespace} = [src];};

  mkPackageCache = packages:
    pkgs.stdenvNoCC.mkDerivation {
      name = "";

      dontUnpack = true;

      installPhase = ''
        mkdir $out

        ${
          builtins.toString (builtins.map (package: let
              inherit ((builtins.fromTOML (builtins.readFile "${package}/typst.toml")).package) name version;
              namespace = builtins.elemAt (lists.reverseList (strings.split "/" (builtins.elemAt (strings.split "/${name}" package) 0))) 0;
            in ''
              echo ${builtins.toString package}
              mkdir -p $out/typst/packages/${namespace}/${name}
              ln -s ${package} $out/typst/packages/${namespace}/${name}/${version}
            '')
            packages)
        }
      '';
    };
}

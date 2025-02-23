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
        cp --recursive "${src}" "$out/${namespace}/${name}/${version}"
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
          else if builtins.isPath elem && builtins.pathExists elem
          then [elem]
          else if builtins.isString elem && builtins.pathExists elem
          then [elem]
          else if builtins.isAttrs elem
          then attrsets.collect isDerivation elem
          else throw "Unsupported input."
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
          "${package.name}:${package.version}" = package;
          ${package.name} = {
            ${package.version} = package;
            ${major}.${minor}.${patch} = package;
          };
        })
      {} (getTypstPackagePathsFromList (builtins.map (src:
        if builtins.isAttrs src
        then getDerivationPackages src
        else src)
      packageSrcs)))
    srcs;

    attrsets = pkgs.lib.attrsets;
    isDerivation = x: x ? "type" && x.type == "derivation";
    getDerivationPackages = attrsets.filterAttrs (name: value: isDerivation value);

    absolutePaths = attrsets.concatMapAttrs (namespace: packages:
      attrsets.concatMapAttrs (name: value: {"${namespace}/${name}" = value;}) (getDerivationPackages packages))
    packageSetWithoutAbsolutePaths;
  in
    packageSetWithoutAbsolutePaths // absolutePaths;

  getPackageImports = let
    strings = pkgs.lib.strings;
    lists = pkgs.lib.lists;
    attersets = pkgs.lib.attrsets;
    namespace = ".*";
    packageName = namespace;
    version = "[0-9]+\\.[0-9]+\\.[0-9]+";
    getImportsFromFile = typstFile: builtins.filter (x: !(x == null)) (builtins.map (builtins.match "[[:blank:]]*\"@(${namespace}/${packageName}:${version})\".*") (strings.splitString "import" (builtins.readFile typstFile)));
  in
    src:
      lists.flatten (attersets.collect builtins.isList (builtins.mapAttrs (fileName: fileType:
        if fileType == "regular" && (builtins.match ".*\.typ" fileName) != null
        then getImportsFromFile "${src}/${fileName}"
        else if fileType == "directory"
        then getPackageImports "${src}/${fileName}"
        else []) (builtins.readDir src)));
}

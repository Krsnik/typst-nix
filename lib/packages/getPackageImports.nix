{ lib }:
let
  inherit (lib) strings lists attrsets;
  namespace = ".*";
  packageName = namespace;
  version = "[0-9]+\\.[0-9]+\\.[0-9]+";

  hasComment = line: (builtins.match ".*(//).*" line) == null;

  matchImport =
    x: builtins.match ".*import[[:blank:]]*\"@(${namespace}/${packageName}:${version})\".*" x;

  getImportsFromFile =
    typstFile:
    builtins.filter (x: !(x == null)) (
      builtins.map matchImport (
        builtins.filter hasComment (strings.splitString "\n" (builtins.readFile typstFile))
      )
    );

  getPackageImports =
    src:
    lists.flatten (
      attrsets.collect builtins.isList (
        builtins.mapAttrs (
          fileName: fileType:
          if fileType == "regular" && (builtins.match ".*\.typ" fileName) != null then
            getImportsFromFile "${src}/${fileName}"
          else if fileType == "directory" then
            getPackageImports "${src}/${fileName}"
          else
            [ ]
        ) (builtins.readDir src)
      )
    );
in
getPackageImports

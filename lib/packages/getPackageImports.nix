{ lib }:
let
  inherit (lib) strings lists attrsets;
  namespace = ".*";
  packageName = namespace;
  version = "[0-9]+\\.[0-9]+\\.[0-9]+";

  getImportsFromFile =
    typstFile:
    builtins.filter (x: !(x == null)) (
      builtins.map (builtins.match "[[:blank:]]*\"@(${namespace}/${packageName}:${version})\".*") (
        strings.splitString "import" (builtins.readFile typstFile)
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

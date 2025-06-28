{ lib }:
let
  inherit (lib) strings lists attrsets;

  getDirectoryPart =
    # /path/to/a -> /path/to/a
    # /path/to/a/file.ext -> /path/to/a
    filePath:
    let
      fileType = builtins.readFileType filePath;
    in
    if fileType == "regular" then
      builtins.dirOf filePath
    else if fileType == "directory" then
      filePath
    else
      abort "Cannot get directory part of '${filePath}'.";

  getFilenamePart =
    # /path/to/a/file.ext -> file.ext
    filePath:
    let
      fileType = builtins.readFileType filePath;
    in
    if fileType == "regular" then
      builtins.baseNameOf filePath
    else
      abort "Cannot get filename part of '${filePath}'.";

  hasComment = line: (builtins.match ".*(//).*" line) == null;

  matchImport =
    x:
    let
      namespace = ".*";
      packageName = namespace;
      version = "[0-9]+\\.[0-9]+\\.[0-9]+";
    in
    builtins.match ".*import[[:blank:]]*\"@(${namespace}/${packageName}:${version})\".*" x;

  getPackageImportsFromFile =
    typstFile:
    builtins.filter (x: !(x == null)) (
      builtins.map matchImport (
        builtins.filter hasComment (strings.splitString "\n" (builtins.readFile typstFile))
      )
    );

  sanitizeInputs =
    src:
    let
      fileType = builtins.readFileType src;
    in
    if fileType == "regular" then
      { "${getFilenamePart src}" = fileType; }
    else if fileType == "directory" then
      builtins.readDir src
    else
      abort "Cannot get file type of '${src}'.";

  getPackageImports =
    src:
    attrsets.collect builtins.isList (
      builtins.mapAttrs (
        fileName: fileType:
        if fileType == "regular" && (builtins.match ".*\.typ" fileName) != null then
          getPackageImportsFromFile "${getDirectoryPart src}/${fileName}"
        else if fileType == "directory" then
          getPackageImports "${getDirectoryPart src}/${fileName}"
        else
          [ ]
      ) (sanitizeInputs src)
    );
in
src: lists.unique (lists.flatten (getPackageImports src))

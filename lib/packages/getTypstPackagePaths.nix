{ lib }:
let
  inherit (lib) lists attrsets;
  getTypstPackagePaths =
    dir:
    let
      contents = builtins.readDir dir;
      subdirs = builtins.filter (x: x != null) (
        attrsets.mapAttrsToList (
          key: value: if value == "directory" || value == "symlink" then key else null
        ) contents
      );
    in
    if builtins.elem "typst.toml" (builtins.attrNames contents) then
      [ dir ]
    else
      lists.unique (
        lists.flatten (builtins.map (subdir: getTypstPackagePaths "${dir}/${subdir}") subdirs)
      );
in
getTypstPackagePaths

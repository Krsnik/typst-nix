# Recurse through all *.typ files in `src` and return a list of packages that were found in `typstPackages`.

{
  lib,
  typstPackages,
  getPackageImports,
}:
let
  inherit (lib) attrsets;
in
src:
builtins.foldl' (
  acc: elem:
  acc
  ++ (
    if typstPackages ? "${elem}" then [ (attrsets.getAttrFromPath [ elem ] typstPackages) ] else [ ]
  )
) [ ] (getPackageImports src)

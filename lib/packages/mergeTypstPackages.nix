{ pkgs, lib }:
packagesOrPackageSets:
let
  inherit (lib) attrsets;
  isDerivation = x: x ? "type" && x.type == "derivation";
in
pkgs.symlinkJoin {
  name = "";
  paths = builtins.foldl' (
    acc: elem:
    acc
    ++ (
      if isDerivation elem then
        [ elem ]
      else if builtins.isPath elem && builtins.pathExists elem then
        [ elem ]
      else if builtins.isString elem && builtins.pathExists elem then
        [ elem ]
      else if builtins.isAttrs elem then
        attrsets.collect isDerivation elem
      else
        throw "Unsupported input."
    )
  ) [ ] packagesOrPackageSets;
}

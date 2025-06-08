{ lib, getTypstPackagePaths }:
let
  lists = lib.lists;
in
packages: lists.unique (lists.flatten (builtins.map getTypstPackagePaths packages))

{
  pkgs,
  lib,
  ...
}: let
  packagePreview = lib.mkTypstPackage {
    src = ./src;
    namespace = "preview";
  };
  packageOtherNamespace = lib.mkTypstPackage {
    src = ./src;
    namespace = "otherNamespace";
  };
  packages = lib.mkTypstPackageSet {
    preview = [./src];
    otherNamespace = [./src];
  };
in
  assert packages
  == {
    "preview/example:0.1.0" = packagePreview;
    preview.example."0.1.0" = packagePreview;
    preview.example."0"."1"."0" = packagePreview;
    "otherNamespace/example:0.1.0" = packageOtherNamespace;
    otherNamespace.example."0.1.0" = packageOtherNamespace;
    otherNamespace.example."0"."1"."0" = packageOtherNamespace;
  };
    pkgs.runCommandLocal "mkTypstPackageSet" {} "mkdir $out"

{
  pkgs,
  lib,
}:
lib.mkTypstPackageSet {
  preview = [lib.previewPackagesRepository];
}

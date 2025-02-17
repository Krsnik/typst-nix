{
  pkgs,
  lib,
}:
lib.mkTypstPackage {
  src = lib.previewPackagesRepository;
}

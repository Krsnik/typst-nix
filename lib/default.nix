{
  pkgs,
  previewPackagesRepository,
} @ args: let
  typstPackages = pkgs.callPackage ./typstPackage.nix {};
  mkTypstProject = pkgs.callPackage ./mkTypstProject.nix {};
  watchTypstProject = pkgs.callPackage ./watchTypstProject.nix {};
  mkTypstShell = pkgs.callPackage ./mkTypstShell.nix {};
in {
  shell = mkTypstShell {};

  mkTypstPackage = typstPackages.mkPackage;
  mkTypstPackageSet = typstPackages.mkPackageSet;
  mergePackageSets = typstPackages.mergePackageSets;
  toPackageList = typstPackages.toPackageList;

  mkProject = {
    src,
    watchPath ? builtins.baseNameOf src,
    name ? "main",
    entrypoint ? "main.typ",
    fonts ? null,
    inputs ? null,
    format ? "pdf",
    ppi ? 144,
    packages ? [],
    enablePreviewPackages ? false,
    previewPackagesRepository ? args.previewPackagesRepository,
  }: let
    packageList =
      if enablePreviewPackages
      then packages ++ [previewPackagesRepository]
      else packages ++ [];
  in {
    watch = {
      open ? false,
      viewer ? "${pkgs.zathura}/bin/zathura",
      out ? "./.preview",
    }: {
      program = "${watchTypstProject {
        inherit name entrypoint fonts inputs format ppi open viewer out;
        packages = packageList;
        src = watchPath;
      }}/bin/watch";
      type = "app";
    };

    build = mkTypstProject {
      inherit src name entrypoint fonts inputs format ppi;
      packages = packageList;
    };

    shell = mkTypstShell {
      inherit fonts;
      packages = packageList;
    };
  };
}

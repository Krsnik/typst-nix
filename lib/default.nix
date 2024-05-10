{pkgs}: let
  typstPackages = pkgs.callPackage ./typstPackage.nix {};
  mkTypstProject = pkgs.callPackage ./mkTypstProject.nix {};
  watchTypstProject = pkgs.callPackage ./watchTypstProject.nix {};
  mkTypstShell = pkgs.callPackage ./mkTypstShell.nix {};
in {
  shell = mkTypstShell {};

  mkTypstPackage = typstPackages.mkPackage;
  mkTypstPackageSet = typstPackages.mkPackageSet;
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
    previewPackagesRepository ? "${
      (pkgs.fetchFromGitHub {
        owner = "typst";
        repo = "packages";
        rev = "3fdc5567a7027833212b465af5c19d59325c75ba";
        sha256 = "B6aH3EQhAukMsuZBvv975KNs7d8pHX2jMc2uppho/1Q=";
      })
    }/packages",
  }: let
    packageList = typstPackages.toPackageList (
      if enablePreviewPackages
      then packages ++ [previewPackagesRepository]
      else packages
    );
  in {
    watch = {
      open ? false,
      editor ? "${pkgs.zathura}/bin/zathura",
      out ? "./.preview",
    }: {
      program = "${watchTypstProject {
        inherit name entrypoint fonts inputs format ppi open editor out;
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

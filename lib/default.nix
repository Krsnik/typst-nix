args@{
  pkgs,
  typstPackages ? { },
}:
rec {
  mkTypstDerivation = pkgs.callPackage ./mkTypstDerivation.nix { inherit mergeTypstPackages; };
  mkTypstShell = pkgs.callPackage ./mkTypstShell.nix { inherit mergeTypstPackages; };
  mkWatchTypstProject = pkgs.callPackage ./mkWatchTypstProject.nix { inherit mergeTypstPackages; };

  # Functions pertaining to packages
  inherit (pkgs.callPackage ./packages { })
    mkTypstPackage
    mkTypstPackageSet
    mergeTypstPackages
    getPackageImports
    ;

  mkTypstProject = pkgs.callPackage ./mkTypstProject.nix {
    inherit
      getPackageImports
      mkTypstDerivation
      mkWatchTypstProject
      mkTypstShell
      ;
    inherit (pkgs.callPackage ./utils.nix { }) stripStorePrefix;
    typstPackages = args.typstPackages;
  };

  # Shell with just Typst
  shell = mkTypstShell { };
}

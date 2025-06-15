args@{
  pkgs,
  typstPackages,
}:
let
  inherit (pkgs) callPackage;
in
rec {
  mkTypstDerivation = callPackage ./mkTypstDerivation.nix { inherit mergeTypstPackages; };
  mkTypstShell = callPackage ./mkTypstShell.nix { inherit mergeTypstPackages; };
  mkWatchTypstProject = callPackage ./mkWatchTypstProject.nix { inherit mergeTypstPackages; };

  # Functions pertaining to packages
  inherit (callPackage ./packages { inherit typstPackages; })
    mkTypstPackage
    mkTypstPackageSet
    mergeTypstPackages
    getPackageImports
    autoDiscoverPackages
    mkTypstPackagesRepository
    ;

  mkTypstProject = callPackage ./mkTypstProject.nix {
    inherit
      getPackageImports
      mkTypstDerivation
      mkWatchTypstProject
      mkTypstShell
      ;
    inherit (callPackage ./utils.nix { }) stripStorePrefix;
    typstPackages = args.typstPackages;
  };

  # Shell with just Typst
  shell = mkTypstShell { };
}

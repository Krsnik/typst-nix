{ pkgs }:
rec {
  getPackageImports = pkgs.callPackage ./getPackageImports.nix { };
  autoDiscoverPackages = pkgs.callPackage ./autoDiscoverPackages { inherit getPackageImports; };
  getTypstPackagePaths = pkgs.callPackage ./getTypstPackagePaths.nix { };
  getTypstPackagePathsFromList = pkgs.callPackage ./getTypstPackagePathsFromList.nix {
    inherit getTypstPackagePaths;
  };
  mkTypstPackage = pkgs.callPackage ./mkTypstPackage.nix { };
  mergeTypstPackages = pkgs.callPackage ./mergeTypstPackages.nix { };
  mkTypstPackageSet = pkgs.callPackage ./mkTypstPackageSet.nix {
    inherit mkTypstPackage getTypstPackagePathsFromList;
  };
}

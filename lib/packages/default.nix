{
  pkgs,
  typstPackages,
}:
let
  inherit (pkgs) callPackage;
in
rec {
  getPackageImports = callPackage ./getPackageImports.nix { };
  autoDiscoverPackages = callPackage ./autoDiscoverPackages.nix {
    inherit getPackageImports typstPackages;
  };
  getTypstPackagePaths = callPackage ./getTypstPackagePaths.nix { };
  getTypstPackagePathsFromList = callPackage ./getTypstPackagePathsFromList.nix {
    inherit getTypstPackagePaths;
  };
  mkTypstPackage = callPackage ./mkTypstPackage.nix { inherit autoDiscoverPackages; };
  mergeTypstPackages = callPackage ./mergeTypstPackages.nix { };
  mkTypstPackageSet = callPackage ./mkTypstPackageSet.nix {
    inherit mkTypstPackage getTypstPackagePathsFromList;
  };
  mkTypstPackagesRepository = callPackage ./mkTypstPackagesRepository.nix {
    inherit mkTypstPackageSet;
  };
}

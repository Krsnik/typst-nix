args: {
  autoDiscoverPackages = import ./autoDiscoverPackages args;
  mergeTypstPackages = import ./mergeTypstPackages args;
  mkTypstDerivation = import ./mkTypstDerivation args;
  mkTypstDerivationHTML = import ./mkTypstDerivationHTML args;
  mkTypstDerivationTypstPackages = import ./mkTypstDerivationTypstPackages args;
  mkWatchTypstProject = import ./mkWatchTypstProject args;
  mkTypstPackage = import ./mkTypstPackage args;
  mkWatchTypstProjectHTML = import ./mkWatchTypstProjectHTML args;
  mkTypstPackageSet = import ./mkTypstPackageSet args;
  nestedPackage = import ./nestedPackage args;
  overlays = import ./overlays args;
}

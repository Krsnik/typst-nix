{
  pkgs,
  lib,
  ...
}: let
  package1 = lib.mkTypstPackage {
    src = ./src;
    namespace = "namespace1";
  };
  package2 = lib.mkTypstPackage {
    src = ./src;
    namespace = "namespace2";
  };
  packageSet1 = lib.mkTypstPackageSet {
    namespace3 = [./src];
    namespace4 = [./src];
  };
  packageSet2 = lib.mkTypstPackageSet {
    namespace4 = [./src];
    namespace5 = [./src];
  };
  mergedPackages = lib.mergeTypstPackages [package1 package2 packageSet1 packageSet2];
in
  pkgs.runCommandLocal "mergeTypstPackage" {
    src = mergedPackages;
  } ''
      ls -la
    packages=(
    "namespace0/${package1.name}/${package1.version}/"
    "namespace2/${package1.name}/${package1.version}/"
    "namespace3/${package1.name}/${package1.version}/"
    "namespace4/${package1.name}/${package1.version}/"
    "namespace5/${package1.name}/${package1.version}/"
    )

    for package in ''${packages[@]}; do
    if ! [ -d "$src/$package" ]; then
        echo "Could not find package '$package'"
        exit 1
    fi
    done

    mkdir $out
  ''

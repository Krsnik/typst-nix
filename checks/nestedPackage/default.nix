{
  pkgs,
  lib,
}: let
  package = lib.mkTypstPackage {
    src = ./src;
    namespace = "namespace1";
  };
  nested = lib.mkTypstPackage {
    src = ./src;
    namespace = "namespace2";
    packages = [package];
  };
in
  pkgs.runCommandLocal "nested Package check" {
    src = nested;
  } ''
    packages=(
      "namespace2/${package.name}/${package.version}/"
      "namespace2/${package.name}/${package.version}/"
    )

    for package in ''${packages[@]}; do
      if ! [ -d "$src/$package" ]; then
        echo "Could not find package '$package'"
        exit 1
      fi
    done

    mkdir $out
  ''

{ pkgs, lib, ... }:
let
  getDirectoryTree =
    src:
    builtins.mapAttrs (
      name: value: if value == "directory" then getDirectoryTree "${src}/${name}" else true
    ) (builtins.readDir src);

  package = lib.mkTypstPackage { src = ./src; };
  packageWithOtherNamespace = lib.mkTypstPackage {
    src = ./src;
    namespace = "namespace1";
  };
  packageWithDependencies = lib.mkTypstPackage {
    src = ./src;
    packages = [ packageWithOtherNamespace ];
  };
in
assert
  getDirectoryTree package == {
    "preview" = {
      "example" = {
        "0.1.0" = {
          "typst.toml" = true;
          "main.typ" = true;
        };
      };
    };
  };
assert
  getDirectoryTree packageWithOtherNamespace == {
    "namespace1" = {
      "example" = {
        "0.1.0" = {
          "typst.toml" = true;
          "main.typ" = true;
        };
      };
    };
  };
assert
  getDirectoryTree packageWithDependencies == {
    "preview" = {
      "example" = {
        "0.1.0" = {
          "typst.toml" = true;
          "main.typ" = true;
        };
      };
    };
    "namespace1" = {
      "example" = {
        "0.1.0" = {
          "typst.toml" = true;
          "main.typ" = true;
        };
      };
    };
  };
pkgs.runCommandLocal "mkTypstPackage" { } "mkdir $out"

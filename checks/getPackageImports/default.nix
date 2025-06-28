{
  pkgs,
  lib,
  ...
}:
let
  # Get Imports from a file.
  packageImportsNoTypstFile = lib.getPackageImports ./src/imports.txt;
  packageImportsTypstFile = lib.getPackageImports ./src/imports.typ;
  packageImportsTypstFileWithoutImports = lib.getPackageImports ./src/noImports.typ;
  packageImportsTypstFileWithDuplicateImports = lib.getPackageImports ./src/duplicateImports.typ;

  # Recursive
  packageImportsFromNestedDirectory = lib.getPackageImports ./src;
in
assert packageImportsNoTypstFile == [ ];
assert
  packageImportsTypstFile == [
    "preview/example:0.1.0"
    "preview/example:0.2.0"
  ];
assert packageImportsTypstFileWithoutImports == [ ];
assert packageImportsTypstFileWithDuplicateImports == [ "preview/duplicate:0.1.0" ];
assert
  packageImportsFromNestedDirectory == [
    "preview/duplicate:0.1.0"
    "preview/example:0.1.0"
    "preview/example:0.2.0"
    "nested/duplicate:0.1.0"
    "nested/example:0.1.0"
    "nested/example:0.2.0"
  ];

pkgs.runCommandLocal "getPackageImports" { } "mkdir $out"

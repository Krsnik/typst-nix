{
  pkgs,
  typst ? pkgs.typst,
}: let
  strings = pkgs.lib.strings;
  typstPackages = pkgs.callPackage ./typstPackage.nix {};
in
  {
    fonts ? null,
    packages ? [],
  }:
    pkgs.mkShellNoCC {
      TYPST_FONT_PATHS =
        if fonts != null
        then strings.concatStringsSep ":" fonts
        else null;

      XDG_DATA_HOME =
        if packages != []
        then typstPackages.mkPackageCache packages
        else null;

      packages = [
        typst
      ];
    }

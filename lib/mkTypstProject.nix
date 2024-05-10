{
  pkgs,
  typst ? pkgs.typst,
}: let
  strings = pkgs.lib.strings;
  typstPackage = pkgs.callPackage ./typstPackage.nix {};
in
  {
    src,
    name ? "main",
    entrypoint ? "main.typ",
    fonts ? null,
    inputs ? null,
    format ? "pdf",
    ppi ? 144,
    packages ? [],
  }: let
    allowedFormats = ["pdf" "png" "svg"];
    checkedFormat =
      if builtins.elem format allowedFormats
      then format
      else throw "${format} is not in allowedFormats [${builtins.toString allowedFormats}]";
  in
    pkgs.stdenvNoCC.mkDerivation {
      inherit name src;

      nativeBuildInputs = [
        typst
      ];

      buildPhase = ''
        XDG_DATA_HOME=${typstPackage.mkPackageCache packages} typst compile ${entrypoint} \
        ${
          if fonts != null
          then "--font-path ${strings.concatStringsSep ":" fonts}"
          else ""
        } \
        ${
          if inputs != null
          then strings.concatStringsSep " " (builtins.map (attr: "--input ${attr}=${inputs.${attr}}") (builtins.attrNames inputs))
          else ""
        } \
        --ppi ${builtins.toString ppi} \
        ${name}${
          if builtins.elem checkedFormat ["png" "svg"]
          then "{n}"
          else ""
        }.${checkedFormat}
      '';

      installPhase = ''
        mkdir $out
        install -m 444 ${name}*.${checkedFormat} $out
      '';
    }

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
    open ? false,
    editor ? "${pkgs.zathura}/bin/zathura",
    out ? "./.preview",
  }: let
    allowedFormats = ["pdf" "png" "svg"];
    checkedFormat =
      if builtins.elem format allowedFormats
      then format
      else throw "${format} is not in allowedFormats [${builtins.toString allowedFormats}]";
  in
    pkgs.writeShellScriptBin "watch" ''
      mkdir -p ${out}
      XDG_DATA_HOME=${typstPackage.mkPackageCache packages} ${typst}/bin/typst watch ${src}/${entrypoint} \
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
      ${
        if open
        then "--open ${editor}"
        else ""
      } \
        ${out}/${name}${
        if builtins.elem checkedFormat ["png" "svg"]
        then "{n}"
        else ""
      }.${checkedFormat}
    ''

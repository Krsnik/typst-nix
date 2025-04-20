{pkgs}: let
  strings = pkgs.lib.strings;
  typstPackage = pkgs.callPackage ./typstPackage.nix {};
in
  {
    src,
    name ? strings.removeSuffix ".typ" (builtins.baseNameOf entrypoint),
    entrypoint ? "main.typ",
    fonts ? [],
    packages ? [],
    inputs ? {},
    format ? "pdf", # The format of the output file.
    ppi ? 144, # The PPI (pixels per inch) to use for PNG export
    typst ? pkgs.typst,
    numberFormat ? "{0p}-of-{t}", # The format of the output file, inferred from the extension by default.
    creationTimestamp ? 0, # The document's creation date formatted as a UNIX timestamp.
    pages ? "1-", # Which pages to export. When unspecified, all document pages are exported.
    jobs ? 0, # Number of parallel jobs spawned during compilation, defaults to number of CPUs.
    timings ? false, # Produces performance timings of the compilation process (experimental).
  }: let
    allowedFormats = ["pdf" "png" "svg" "html"];
    checkedFormat =
      if builtins.elem format allowedFormats
      then
        if format == "html" && (builtins.compareVersions typst.version "0.13.0") < 0
        then throw "HTML export is only supported for Typst versions >= '0.13.0'. Current version: '${typst.version}'."
        else format
      else throw "'${format}' is not in allowedFormats [${builtins.toString allowedFormats}]";
  in
    pkgs.stdenvNoCC.mkDerivation {
      inherit src name;

      nativeBuildInputs = [
        typst
      ];

      buildPhase = ''
        ${
          if timings
          then "mkdir -p $out/dev"
          else "mkdir $out"
        }

        typst compile "${entrypoint}" \
        --jobs "${builtins.toString jobs}" \
        --creation-timestamp "${builtins.toString creationTimestamp}" \
        ${
          if packages != []
          then ''--package-path "${typstPackage.mergeTypstPackages packages}"''
          else ""
        } \
        --ignore-system-fonts \
        ${
          if fonts != [] && format != "html"
          then ''--font-path "${strings.concatStringsSep ":" fonts}"''
          else ""
        } \
        ${
          if inputs != {}
          then strings.concatStringsSep " " (builtins.map (attr: "--input '${attr}=${builtins.toString inputs.${attr}}'") (builtins.attrNames inputs))
          else ""
        } \
        --pages "${pages}" \
        --ppi "${builtins.toString ppi}" \
        ${
          if timings
          then "--timings $out/dev/timings.json"
          else ""
        } \
        --features html \
        "$out/${name}${
          if builtins.elem checkedFormat ["png" "svg"]
          then numberFormat
          else ""
        }.${checkedFormat}"
      '';
    }

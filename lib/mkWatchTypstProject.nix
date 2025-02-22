{pkgs}: let
  strings = pkgs.lib.strings;
  typstPackage = pkgs.callPackage ./typstPackage.nix {};
in
  {
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
    open ? false,
    viewer ? "${pkgs.zathura}/bin/zathura",
    out ? null, # Which directory to save the temporary output. Default: Create a new temporary directory.
    keepOut ? false,
    timings ? false, # Produces performance timings of the compilation process (experimental).
  }: let
    allowedFormats = ["pdf" "png" "svg"];
    checkedFormat =
      if builtins.elem format allowedFormats
      then format
      else throw "'${format}' is not in allowedFormats [${builtins.toString allowedFormats}]";
  in
    pkgs.writeShellApplication {
      name = "watch";

      runtimeInputs = [typst];

      text = ''
        TYPST_WATCH_DIRECTORY="${
          if out != null
          then out
          else "$(mktemp --directory)"
        }"

        ${
          if timings
          then ''mkdir -p "$TYPST_WATCH_DIRECTORY/dev"''
          else ""
        }

        ${
          if !keepOut
          then ''trap 'rm -r "$TYPST_WATCH_DIRECTORY"' EXIT''
          else ""
        }

        # TODO: timings $out/$${timings_name_timings}.json

        typst watch "${entrypoint}" \
        --jobs "${builtins.toString jobs}" \
        --creation-timestamp "${builtins.toString creationTimestamp}" \
        ${
          if packages != []
          then ''--package-path "${typstPackage.mergeTypstPackages packages}"''
          else ""
        } \
        --ignore-system-fonts \
        ${
          if fonts != []
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
          if open
          then ''--open "${viewer}"''
          else ""
        } \
        ${
          if timings
          then ''--timings "$TYPST_WATCH_DIRECTORY/dev/timings.json"''
          else ""
        } \
        "$TYPST_WATCH_DIRECTORY/${name}${
          if builtins.elem checkedFormat ["png" "svg"]
          then numberFormat
          else ""
        }.${checkedFormat}"
      '';
    }

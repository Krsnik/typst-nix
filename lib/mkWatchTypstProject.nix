{
  pkgs,
  lib,
  mergeTypstPackages,
}:
let
  inherit (lib) strings;
in
{
  name ? strings.removeSuffix ".typ" (builtins.baseNameOf entrypoint),
  entrypoint ? "main.typ",
  fonts ? [ ],
  packages ? [ ],
  inputs ? { },
  format ? "pdf", # The format of the output file.
  ppi ? 144, # The PPI (pixels per inch) to use for PNG export
  typst ? pkgs.typst,
  numberFormat ? "{0p}-of-{t}", # The format of the output file, inferred from the extension by default.
  creationTimestamp ? 0, # The document's creation date formatted as a UNIX timestamp.
  pages ? "1-", # Which pages to export. When unspecified, all document pages are exported.
  jobs ? 0, # Number of parallel jobs spawned during compilation, defaults to number of CPUs.
  open ? false,
  viewer ?
    if format == "html" then
      "${pkgs.xdg-utils}/bin/xdg-open" # Open in default browser.
    else
      "${pkgs.zathura}/bin/zathura", # Open in a lightweight, automatically reloading PDF and image viewer.
  out ? null, # Which directory to save the temporary output. Default: Create a new temporary directory.
  keepOut ? false,
  timings ? false, # Produces performance timings of the compilation process (experimental).
  port ? null, # The port where HTML is served.
  noServe ? false, # Disables the built-in HTTP server for HTML export.
  noReload ? false, # Disables the injected live reload script for HTML export.
}:
let
  allowedFormats = [
    "pdf"
    "png"
    "svg"
    "html"
  ];
  checkedFormat =
    if builtins.elem format allowedFormats then
      if format == "html" && (builtins.compareVersions typst.version "0.13.0") < 0 then
        throw "HTML export is only supported for Typst versions >= '0.13.0'. Current version: '${typst.version}'."
      else
        format
    else
      throw "'${format}' is not in allowedFormats [${builtins.toString allowedFormats}]";
in
pkgs.writeShellApplication {
  name = "watch";

  runtimeInputs = [ typst ];

  text = ''
    TYPST_WATCH_DIRECTORY="${if out != null then out else "$(mktemp --directory)"}"

    mkdir -p "$TYPST_WATCH_DIRECTORY"

    ${if timings then ''mkdir -p "$TYPST_WATCH_DIRECTORY/dev"'' else ""}

    ${if !keepOut then ''trap 'rm -r "$TYPST_WATCH_DIRECTORY"' EXIT'' else ""}

    typst watch "${entrypoint}" \
    --jobs "${builtins.toString jobs}" \
    --creation-timestamp "${builtins.toString creationTimestamp}" \
    ${if packages != [ ] then ''--package-path "${mergeTypstPackages packages}"'' else ""} \
    --ignore-system-fonts \
    ${if fonts != [ ] then ''--font-path "${builtins.concatStringsSep ":" fonts}"'' else ""} \
    ${
      if inputs != { } then
        builtins.concatStringsSep " " (
          builtins.map (attr: "--input '${attr}=${builtins.toString inputs.${attr}}'") (
            builtins.attrNames inputs
          )
        )
      else
        ""
    } \
    --pages "${pages}" \
    --ppi "${builtins.toString ppi}" \
    ${if open then ''--open "${viewer}"'' else ""} \
    ${if timings then ''--timings "$TYPST_WATCH_DIRECTORY/dev/timings.json"'' else ""} \
    ${if format == "html" then "--features html" else ""} \
    ${if format == "html" && port != null then "--port ${builtins.toString port}" else ""} \
    ${if format == "html" && noServe then "--no-serve" else ""} \
    ${if format == "html" && noReload then "--no-reload" else ""} \
    "$TYPST_WATCH_DIRECTORY/${name}${
      if
        builtins.elem checkedFormat [
          "png"
          "svg"
        ]
      then
        numberFormat
      else
        ""
    }.${checkedFormat}"
  '';
}

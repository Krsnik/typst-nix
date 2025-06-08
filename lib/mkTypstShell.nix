{
  pkgs,
  mergeTypstPackages,
}:
{
  typst ? pkgs.typst,
  fonts ? [ ],
  packages ? [ ],
  creationTimestamp ? 0, # The document's creation date formatted as a UNIX timestamp.
}:
pkgs.mkShellNoCC {
  "SOURCE_DATE_EPOCH" = builtins.toString creationTimestamp;

  "TYPST_FONT_PATHS" = if fonts != [ ] then builtins.concatStringsSep ":" fonts else null;

  "TYPST_PACKAGE_PATH" = if packages != [ ] then mergeTypstPackages packages else null;

  packages = [
    typst
  ];
}

args @ {
  pkgs,
  typstPackages ? {},
}: rec {
  # Expose library functions #
  mkTypstDerivation = pkgs.callPackage ./mkTypstDerivation.nix {};
  mkTypstShell = pkgs.callPackage ./mkTypstShell.nix {};
  mkWatchTypstProject = pkgs.callPackage ./mkWatchTypstProject.nix {};

  # Functions pertaining to packages
  typstPackages = pkgs.callPackage ./typstPackage.nix {};
  inherit (typstPackages) mkTypstPackage mkTypstPackageSet mergeTypstPackages getPackageImports;

  # Shell with just Typst
  shell = mkTypstShell {};

  # Create a project with build and run options
  mkTypstProject = let
    strings = pkgs.lib.strings;
    attrsets = pkgs.lib.attrsets;
  in
    {
      src,
      entrypoint ? "main.typ",
      name ? strings.removeSuffix ".typ" (builtins.baseNameOf entrypoint),
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
      # enableTypstPackages ? false, # This will enable ALL typst packages and cause 600+ MiB dependency!
      autoDiscoverPackages ? true, # This will look through the source code and try to find official typst package import and only include them when building.
      typstPackages ?
        if autoDiscoverPackages && args.typstPackages == {}
        then throw "enableTypstPackages == true but typstPackages is not defined. Define for the library or directly in the function call."
        else args.typstPackages,
    }: let
      mappedPackages =
        packages
        ++ (
          if autoDiscoverPackages
          then
            builtins.foldl' (acc: elem:
              acc
              ++ (
                if typstPackages ? "${elem}"
                then [(attrsets.getAttrFromPath [elem] typstPackages)]
                else []
              )) [] (getPackageImports src)
          else []
        );
    in rec {
      build = mkTypstDerivation {
        inherit src name entrypoint fonts inputs format ppi typst numberFormat creationTimestamp pages jobs timings;
        packages = mappedPackages;
      };

      mkWatch = {
        open ? false,
        viewer ? "${pkgs.zathura}/bin/zathura",
        out ? null,
        keepOut ? false,
      }:
        mkWatchTypstProject {
          inherit name entrypoint fonts inputs format ppi typst numberFormat creationTimestamp pages jobs timings open viewer out keepOut;
          packages = mappedPackages;
        };

      watch = args @ {
        open ? false,
        viewer ? "${pkgs.zathura}/bin/zathura",
        out ? null,
        keepOut ? false,
      }: {
        program = "${mkWatch args}/bin/watch";
        type = "app";
      };

      shell = mkTypstShell {
        inherit typst fonts creationTimestamp;
        packages = mappedPackages;
      };
    };
}

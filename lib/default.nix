args @ {
  pkgs,
  previewPackages ? {},
}: rec {
  # Expose library functions #
  mkTypstDerevation = pkgs.callPackage ./mkTypstDerevation.nix {};
  mkTypstShell = pkgs.callPackage ./mkTypstShell.nix {};
  mkWatchTypstProject = pkgs.callPackage ./mkWatchTypstProject.nix {};

  # Functions pertaining to packages
  typstPackages = pkgs.callPackage ./typstPackage.nix {};
  inherit (typstPackages) mkTypstPackage mkTypstPackageSet;
  # mergeTypstPackageSets = typstPackages.mergePackageSets;
  # toTypstPackageList = typstPackages.toPackageList;

  # Empty shell with just typst
  shell = mkTypstShell {};

  # Expose preview bound previewPackagesRepository
  # inherit previewPackagesRepository;

  # Create a project with build and run options
  mkTypstProject = let
    strings = pkgs.lib.strings;
  in
    {
      src,
      name ? strings.removeSuffix ".typ" (builtins.baseNameOf entrypoint),
      entrypoint ? "main.typ",
      fonts ? [],
      packages ?
        if enablePreviewPackages
        then [previewPackagesRepository]
        else [],
      inputs ? {},
      format ? "pdf", # The format of the output file.
      ppi ? 144, # The PPI (pixels per inch) to use for PNG export
      typst ? pkgs.typst,
      numberFormat ? "{0p}-of-{t}", # The format of the output file, inferred from the extension by default.
      creationTimestamp ? 0, # The document's creation date formatted as a UNIX timestamp.
      pages ? "1-", # Which pages to export. When unspecified, all document pages are exported.
      jobs ? 0, # Number of parallel jobs spawned during compilation, defaults to number of CPUs.
      enablePreviewPackages ? false,
      previewPackagesRepository ?
        if enablePreviewPackages && args.previewPackagesRepository != null
        then args.previewPackagesRepository
        else throw "enablePreviewPackages = true but previewPackagesRepository is not defined.",
    }: rec {
      build = mkTypstDerevation {
        inherit src name entrypoint fonts packages inputs format ppi typst numberFormat creationTimestamp pages jobs;
      };

      mkWatch = {
        open ? false,
        viewer ? "${pkgs.zathura}/bin/zathura",
        out ? null,
        keepOut ? false,
      }:
        mkWatchTypstProject {
          inherit name entrypoint fonts packages inputs format ppi typst numberFormat creationTimestamp pages jobs open viewer out keepOut;
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
        inherit typst fonts packages creationTimestamp;
      };
    };
}

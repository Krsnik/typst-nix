args@{ pkgs, autoDiscoverPackages }:
{
  src, # Path to a typst package. Expects 'typst.toml' at the top level.
  namespace ? "preview", # Name of the namespace the package should appear under.
  packages ? [ ], # Will include (symlinkJoin) into the same derivation.
  # fonts ? [], # TODO/figure out (with builtInputs or an extra attribute perhaps?)
  autoDiscoverPackages ? true,
}:
let
  package = pkgs.stdenvNoCC.mkDerivation rec {
    inherit ((builtins.fromTOML (builtins.readFile "${src}/typst.toml")).package) name version;

    allowSubstitutes = false;

    dontUnpack = true;

    installPhase = ''
      mkdir --parents "$out/${namespace}/${name}"
      cp --recursive "${src}" "$out/${namespace}/${name}/${version}"
    '';
  };

  mappedPackages = packages ++ (if autoDiscoverPackages then args.autoDiscoverPackages src else [ ]);
in
if mappedPackages != [ ] then
  pkgs.symlinkJoin {
    inherit (package) name version;
    paths = mappedPackages ++ [ package ];
  }
else
  package

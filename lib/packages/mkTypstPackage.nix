{ pkgs }:
{
  src, # Path to a typst package. Expects 'typst.toml' at the top level.
  namespace ? "preview", # Name of the namespace the package should appear under.
  packages ? [ ], # Will include (symlinkJoin) into the same derevation.
# fonts ? [], # TODO/figure out (with builtInputs or an extra attribute perhaps?)
}:
let
  package = pkgs.stdenvNoCC.mkDerivation rec {
    inherit ((builtins.fromTOML (builtins.readFile "${src}/typst.toml")).package) name version;

    dontUnpack = true;

    installPhase = ''
      mkdir --parents "$out/${namespace}/${name}"
      cp --recursive "${src}" "$out/${namespace}/${name}/${version}"
    '';
  };
in
if packages != [ ] then
  pkgs.symlinkJoin {
    inherit (package) name version;
    paths = packages ++ [ package ];
  }
else
  package

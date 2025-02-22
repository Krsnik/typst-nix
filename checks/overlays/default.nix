{
  self,
  pkgs,
  ...
}: let
  overlay = self.overlays.default;
  pkgsWithOverlay = pkgs.extend overlay;
  typstPackages = pkgsWithOverlay.typstPackages;
  isDerivation = x: x ? "type" && x.type == "derivation";
in
  assert isDerivation typstPackages."preview/example:0.1.0";
  assert isDerivation typstPackages.preview.example."0.1.0";
  assert isDerivation typstPackages.preview.example."0"."1"."0";
    pkgs.runCommandLocal "overlays" {} "mkdir $out"

{
  self,
  pkgs,
  ...
}: let
  overlay = self.overlays.default;
  pkgsWithOverlay = pkgs.extend overlay;
in
  assert pkgsWithOverlay ? typstPackages;
  assert pkgsWithOverlay.typstPackages ? "preview/example:0.1.0";
  assert pkgsWithOverlay.typstPackages."preview/example:0.1.0" ? type;
  assert pkgsWithOverlay.typstPackages."preview/example:0.1.0".type == "derivation";
  assert pkgsWithOverlay.typstPackages ? preview;
  assert pkgsWithOverlay.typstPackages.preview ? example;
  assert pkgsWithOverlay.typstPackages.preview.example ? "0.1.0";
  assert pkgsWithOverlay.typstPackages.preview.example."0.1.0" ? type;
  assert pkgsWithOverlay.typstPackages.preview.example."0.1.0".type == "derivation";
  assert pkgsWithOverlay.typstPackages.preview.example."0" ? "1";
  assert pkgsWithOverlay.typstPackages.preview.example."0"."1" ? "0";
  assert pkgsWithOverlay.typstPackages.preview.example."0"."1"."0" ? type;
  assert pkgsWithOverlay.typstPackages.preview.example."0"."1"."0".type == "derivation";
    pkgs.runCommandLocal "overlays" {} "mkdir $out"

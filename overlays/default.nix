{ self, ... }:
let
  overlays = {
    typst = final: prev: {
      typst = self.inputs.nixpkgs.legacyPackages.${prev.system}.typst;
    };

    typstPackages = final: prev: {
      typstPackages = self.typstPackages.${prev.system};
    };
  };
in
overlays
// {
  # Expose all package overlays as one overlay
  default = self.inputs.nixpkgs.lib.composeManyExtensions (builtins.attrValues overlays);
}

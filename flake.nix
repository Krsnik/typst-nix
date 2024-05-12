{
  description = "A Typst project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    previewPackagesRepository = {
      url = "github:typst/packages";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    previewPackagesRepository,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "i686-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system});
  in {
    lib = forAllSystems (system:
      import ./lib {
        pkgs = pkgs.${system};
        previewPackagesRepository = "${previewPackagesRepository}/packages";
      });
    templates = import ./templates {};
  };
}

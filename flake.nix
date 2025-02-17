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
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "i686-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in rec {
    previewPackagesRepository = "${inputs.previewPackagesRepository}/packages";

    mkLib = args @ {
      pkgs,
      previewPackagesRepository ? previewPackagesRepository,
    }:
      import ./lib args;

    lib = forAllSystems (system: mkLib {pkgs = pkgs.${system};});

    checks = forAllSystems (system:
      import ./checks {
        pkgs = pkgs.${system};
        lib = self.lib.${system};
      });

    templates = import ./templates {};
  };
}

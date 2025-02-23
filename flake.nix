{
  description = "A library to create Typst projects.";

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
    typstPackages = forAllSystems (system:
      self.lib.${system}.mkTypstPackageSet {
        "preview" = ["${inputs.previewPackagesRepository}/packages/preview/"];
      });

    previewPackages =
      forAllSystems (system:
        typstPackages.${system}.preview);

    packages = forAllSystems (system: let
      attrsets = pkgs.${system}.lib.attrsets;
      isDerivation = x: x ? "type" && x.type == "derivation";
    in
      attrsets.filterAttrs (name: value: isDerivation value) self.typstPackages.${system});

    mkLib = args @ {
      pkgs,
      previewPackages ? self.previewPackages,
    }:
      import ./lib args;

    lib = forAllSystems (system:
      mkLib {
        pkgs = pkgs.${system};
        previewPackages = self.previewPackages;
      });

    checks = forAllSystems (system:
      import ./checks {
        inherit self system;
        pkgs = pkgs.${system};
        lib = self.lib.${system};
      });

    overlays = import ./overlays {
      inherit self;
    };

    templates = import ./templates {};
  };
}

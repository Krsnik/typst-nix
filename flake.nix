{
  description = "A library to create Typst projects.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typstPackagesRepository = {
      url = "github:typst/packages";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    rec {
      typstPackages = forAllSystems (
        system: self.lib.${system}.mkTypstPackagesRepository "${inputs.typstPackagesRepository}/packages"
      );

      previewPackages = forAllSystems (system: typstPackages.${system}.preview);

      packages = forAllSystems (
        system:
        let
          attrsets = pkgs.${system}.lib.attrsets;
          isDerivation = x: x ? "type" && x.type == "derivation";
        in
        attrsets.filterAttrs (name: value: isDerivation value) self.typstPackages.${system}
      );

      mkLib =
        args@{
          pkgs,
          typstPackages ? self.typstPackages.${pkgs.system},
        }:
        import ./lib args;

      lib = forAllSystems (
        system:
        mkLib {
          pkgs = pkgs.${system};
          typstPackages = self.typstPackages.${system};
        }
      );

      checks = forAllSystems (
        system:
        import ./checks {
          inherit self system;
          pkgs = pkgs.${system};
          lib = self.lib.${system};
        }
      );

      overlays = import ./overlays {
        inherit self;
      };

      devShells = forAllSystems (
        system:
        import ./shells {
          inherit self system;
        }
      );

      templates = import ./templates { };
    };
}

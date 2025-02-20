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
    previewPackagesRepository,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "i686-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in rec {
    previewPackagesRepository = "${inputs.previewPackagesRepository}/packages/preview";

    #         builtins.mapAttrs (namespace: packages:
    #   builtins.mapAttrs (
    #     packages: package: let
    #       # Since mapAttrs returns the values in alphabetically sorted order,
    #       # the last element is going to be the highest version.
    #       versions = builtins.attrValues package;
    #       index = (builtins.length versions) - 1;
    #       latestVersion = builtins.elemAt versions index;
    #     in
    #       latestVersion
    #   )
    #   packages)
    # pset

    packages = forAllSystems (
      system:
        self.lib.${system}.typstPackages.mkTypstPackageSet {
          "preview" = [
            "${self.previewPackagesRepository}/zero"
            "${self.previewPackagesRepository}/vartable"
          ];
          "two" = ["${self.previewPackagesRepository}/zero"];
        }
    );

    mkLib = args @ {
      pkgs,
      previewPackagesRepository ? self.previewPackagesRepository,
    }:
      import ./lib args;

    lib = forAllSystems (system:
      mkLib {
        pkgs = pkgs.${system};
        previewPackagesRepository = self.previewPackagesRepository;
      });

    checks = forAllSystems (system:
      import ./checks {
        pkgs = pkgs.${system};
        lib = self.lib.${system};
      });

    templates = import ./templates {};
  };
}

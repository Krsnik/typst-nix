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
    previewPackages = forAllSystems (system:
      self.lib.${system}.typstPackages.mkTypstPackageSet {
        "preview" = ["${inputs.previewPackagesRepository}/packages/preview"];
      });

    packages = forAllSystems (
      system:
        builtins.mapAttrs (
          packageName: package: let
            # Since mapAttrs returns the values in alphabetically sorted order,
            # the last element is going to be the highest version.
            versions = builtins.filter (x: builtins.match "([0-9])\.([0-9])\.([0-9])" != null) (builtins.attrNames package);
            index = (builtins.length versions) - 1;
            latestVersion = builtins.elemAt versions index;
          in
            package.${latestVersion}
        )
        self.previewPackages.${system}.preview
    );

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
        pkgs = pkgs.${system};
        lib = self.lib.${system};
      });

    templates = import ./templates {};
  };
}

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
        "preview" = ["${inputs.previewPackagesRepository}/packages/preview/"];
      });

    packages = forAllSystems (
      system: let
        attrsets = pkgs.${system}.lib.attrsets;
        packages = attrsets.collect (x: x ? "type" && x.type == "derivation") self.previewPackages.${system}.preview;
      in
        builtins.foldl' (acc: package: acc // {"preview/${package.name}:${package.version}" = package;}) {} packages
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
        inherit self system;
        pkgs = pkgs.${system};
        lib = self.lib.${system};
      });

    templates = import ./templates {};
  };
}

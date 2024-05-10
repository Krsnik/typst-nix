{
  description = "A Typst project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typst-nix = {
      url = "github:Krsnik/typst-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    typst-nix,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "i686-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system});
    typst = forAllSystems (system: typst-nix.lib.${system});

    projects = rec {
      example1 = forAllSystems (system:
        typst.${system}.mkProject {
          src = ./src/example1;
          watchPath = "./src/example1";

          name = "example1";

          fonts = with pkgs.${system}; [roboto];
          inputs = {lang = "de";};
        });

      example2 = forAllSystems (system:
        typst.${system}.mkProject {
          src = ./src/example2;
          watchPath = "./src/example2";

          name = "example2";

          packages = [packageSet.${system}];
          enablePreviewPackages = true;
          fonts = with pkgs.${system}; [roboto];
          inputs = {lang = "de";};
        });

      example3 = forAllSystems (system:
        typst.${system}.mkProject {
          src = ./src/example2;
          watchPath = "./src/example2";

          name = "example3";

          packages = [packageSet.${system}];
          enablePreviewPackages = true;
          previewPackagesRepository = "${
            (pkgs.${system}.fetchFromGitHub {
              owner = "typst";
              repo = "packages";
              rev = "3fdc5567a7027833212b465af5c19d59325c75ba";
              sha256 = "B6aH3EQhAukMsuZBvv975KNs7d8pHX2jMc2uppho/1Q=";
            })
          }/packages";
          fonts = with pkgs.${system}; [roboto];
          inputs = {lang = "de";};
        });

      example4 = forAllSystems (system:
        typst.${system}.mkProject {
          src = ./src/example2;
          watchPath = "./src/example2";

          name = "example4";

          packages = [
            packageSet.${system}
            "${
              (pkgs.${system}.fetchFromGitHub {
                owner = "typst";
                repo = "packages";
                rev = "3fdc5567a7027833212b465af5c19d59325c75ba";
                sha256 = "B6aH3EQhAukMsuZBvv975KNs7d8pHX2jMc2uppho/1Q=";
              })
            }/packages"
          ];
          enablePreviewPackages = false;
          fonts = with pkgs.${system}; [roboto];
          inputs = {lang = "de";};
        });

      package1 = forAllSystems (system:
        typst.${system}.mkTypstPackage {
          src = ./src/package1;
          namespace = "namespace1";
        });

      package2 = forAllSystems (system:
        typst.${system}.mkTypstPackage {
          src = ./src/package2;
          namespace = "namespace2";
        });

      packageSet = forAllSystems (system:
        typst.${system}.mkTypstPackageSet {
          "example" = [
            ./src/package1
            ./src/package2
          ];
          "namespace2" = [./src/package2];
        });
    };
  in {
    packages = forAllSystems (system: {
      example1 = projects.example1.${system}.build;
      example2 = projects.example2.${system}.build;
      example3 = projects.example3.${system}.build;
      example4 = projects.example4.${system}.build;

      package1 = projects.package1.${system};
      package2 = projects.package2.${system};

      packageSet = projects.packageSet.${system};
    });

    apps = forAllSystems (system: {
      example1 = projects.example1.${system}.watch {open = true;};
      example2 = projects.example2.${system}.watch {open = true;};
      example3 = projects.example3.${system}.watch {open = true;};
      example4 = projects.example4.${system}.watch {open = true;};
    });

    devShells = forAllSystems (system: {
      default = typst.${system}.shell;

      example1 = projects.example1.${system}.shell;
      example2 = projects.example2.${system}.shell;
      example3 = projects.example3.${system}.shell;
      example4 = projects.example4.${system}.shell;
    });
  };
}

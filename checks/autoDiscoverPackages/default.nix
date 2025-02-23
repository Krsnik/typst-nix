{
  pkgs,
  lib,
  ...
}: let
  project = lib.mkTypstProject {
    src = ./src;
    autoDiscoverPackages = true;
  };
in
  pkgs.runCommandLocal "autoDiscoverPackages" {src = project.build;} "mkdir $out"

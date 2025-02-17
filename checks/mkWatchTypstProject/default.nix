{
  pkgs,
  lib,
}:
lib.mkWatchTypstProject {
  entrypoint = "src/example1/main.typ";
  fonts = with pkgs; [roboto];
  packages = [lib.previewPackagesRepository];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
  open = true;
  out = "./typst/preview";
}

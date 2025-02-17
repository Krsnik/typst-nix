{
  pkgs,
  lib,
}:
lib.mkTypstDerevation {
  src = ./src;
  name = "mkTypstDerevation";
  fonts = with pkgs; [roboto];
  packages = [lib.previewPackagesRepository];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
}

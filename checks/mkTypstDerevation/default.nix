{
  self,
  system,
  pkgs,
  lib,
  ...
}:
lib.mkTypstDerevation {
  src = ./src;
  name = "mkTypstDerevation";
  fonts = with pkgs; [roboto];
  packages = [self.packages.${system}."preview/example:0.1.0"];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
  timings = true;
}

{
  self,
  system,
  pkgs,
  lib,
  ...
}:
lib.mkWatchTypstProject {
  entrypoint = "checks/mkWatchTypstProjectHTML/src/main.typ";
  fonts = with pkgs; [roboto];
  packages = [self.packages.${system}."preview/example:0.1.0"];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
  format = "html";
  open = true;
  out = "./typst/preview";
  viewer = "";
}

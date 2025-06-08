{
  self,
  pkgs,
  lib,
  ...
}:
lib.mkTypstDerivation {
  src = ./src;
  name = "mkTypstDerivationAllTypstPackages";
  fonts = with pkgs; [ roboto ];
  packages = [ "${self.inputs.typstPackagesRepository}/packages" ];
  pages = "2,3-";
  inputs = {
    lang = "de";
    hello = 12;
  };
  timings = true;
}

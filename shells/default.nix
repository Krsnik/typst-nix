{
  self,
  system,
}: rec {
  default = typst;

  # Shell with just Typst
  typst = self.lib.${system}.mkTypstShell {};

  # Shell with Typst and all official Typst packages
  typstWithPackages = self.lib.${system}.mkTypstShell {
    packages = ["${self.inputs.typstPackagesRepository}/packages"];
  };
}

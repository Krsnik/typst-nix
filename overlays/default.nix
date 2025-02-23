{self, ...}: rec {
  default = typstPackages;

  typstPackages = final: prev: {
    typst = self.pkgs.${prev.system}.typst;
    typstPackages = self.typstPackages.${prev.system};
  };
}

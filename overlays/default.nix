{self, ...}: {
  default = final: prev: {
    typst = self.pkgs.${prev.system}.typst;
    typstPackages = self.packages.${prev.system} // self.previewPackages.${prev.system};
  };
}

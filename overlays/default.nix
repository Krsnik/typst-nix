{self, ...}: {
  default = final: prev: {
    typst = self.pkgs.${prev.system}.typst;
    typstPackages = self.previewPackages.${prev.system};
  };
}

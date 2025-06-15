{
  lib,
  mkTypstPackageSet,
}:
typstPackageRepository:
let
  inherit (lib) attrsets;

  namespaces = attrsets.filterAttrs (filename: filetype: filetype == "directory") (
    builtins.readDir typstPackageRepository
  );
  namespacesWithSrcs = attrsets.concatMapAttrs (namespace: value: {
    ${namespace} = [ "${typstPackageRepository}/${namespace}" ];
  }) namespaces;
in
mkTypstPackageSet namespacesWithSrcs

rec {
  removePrefix = prefix: source: let
    sourceLen = builtins.stringLength source;
    prefixLen = builtins.stringLength prefix;
    _checkPrefixIsContained =
      if (builtins.substring 0 prefixLen source) != prefix
      then throw "Source string does not contain prefix '${prefix}'."
      else true;
  in
    assert _checkPrefixIsContained;
      builtins.substring prefixLen (sourceLen - prefixLen) source;

  stripStorePrefix = storePath: let
    rootPath = ./.;
    rootPathString = builtins.toString rootPath;
    storePathString = builtins.toString storePath;
  in
    ./. + "${removePrefix rootPathString storePathString}";
}

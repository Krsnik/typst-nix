{lib}: {
  stripStorePrefix = storePath: let
    # A nix store path looks like this '/nix/store/<hash>-<name>/contents/of/project'.
    # We want to extract the '/contents/of/project' part.
    inherit (lib.strings) removePrefix;

    # Get the '/nix/store' part
    storePrefix = builtins.toString (builtins.dirOf (builtins.dirOf ./.));

    # Remove the '/nix/store' part, which leaves '/<hash>-<name>/contents/of/project'.
    storePathWithPrefixRemoved = removePrefix storePrefix (builtins.toString storePath);

    # Remove the '/<hash>-<name>' part.
    projectName = let
      getFirstDirectory = path:
        if builtins.dirOf path == "/"
        then path
        else getFirstDirectory (builtins.dirOf path);
    in
      getFirstDirectory storePathWithPrefixRemoved;
  in
    removePrefix projectName storePathWithPrefixRemoved;
}

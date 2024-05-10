{}: {
  example = {
    path = ./example;

    description = "A comprehensive example for a Typst project.";

    welcomeText = ''
      Created a comprehensive example for a Typst project.

      * Compile with:
        * `nix build .#example1`

      * Watch with:
        * `nix run .#example1`

      * Enter an environment with the project's dependencies:
        * `nix develop .#example`
    '';
  };
}

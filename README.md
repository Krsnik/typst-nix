# Typst-nix

A nix library to develop and build [Typst](https://typst.app/) projects.

## Features

- Unit Tests
- Create packages
- Allow fonts
- Watch script configured like the build environment.
- Shell environment configures like the build environment.
- Support almost all Typst command line options.

## Documentation

### mkLib

#### Required Arguments

**pkgs**

A `nixpkgs` package set.

#### Optional Arguments

**typstPackages**

Official Typst Repository Packages.
Are set to the `typstPackagesRepository` input.
You can override this input to pin a different version.

### lib.\<system\>

`mkLib` with pinned requirements passed.

### lib.\<system\>.mkTypstProject

#### Required Arguments

**src**

Source of project.

#### Optional Arguments

**entrypoint**

Which file should be treated as the entrypoint.

*Default: main.typ*

**name**

## TODO

- Documentation
- mkTypstPackage
  - Allow for embedding fonts
  - Allow for linking embedding arbitrary data
- mkTypstDerivation
  - Allow for html support. (With version check).
  - Make into an abstract method that the consumer can override parts of.

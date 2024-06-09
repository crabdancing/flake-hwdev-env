{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          freerouting = pkgs.callPackage ./pkgs/freerouting {};
          default = freerouting;
        };
        devShells.default = pkgs.mkShell rec {
          buildInputs = with pkgs;
            [
              (python3.withPackages (p:
                with p; [
                  kicad
                ]))
            ]
            ++ (with packages; [
              freerouting
            ]);
          KICAD7_SYMBOL_DIR = "${pkgs.kicad.libraries.symbols}/share/kicad/symbols";
          KICAD7_FOOTPRINT_DIR = "${pkgs.kicad.libraries.footprints}/share/kicad/footprints";
          KICAD_SYMBOL_DIR = KICAD7_SYMBOL_DIR;
          KICAD_FOOTPRINT_DIR = KICAD7_FOOTPRINT_DIR;
        };
      }
    );
}

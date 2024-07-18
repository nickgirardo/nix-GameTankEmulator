{
  description = "Emulator for the GameTank";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
      in pkgs.stdenv.mkDerivation {
        homepage = "https://github.com/clydeshaffer/GameTankEmulator";
        name = "GameTankEmulator";

        src = pkgs.fetchgit {
          url = "https://github.com/clydeshaffer/GameTankEmulator.git";
          rev = "8bedf39b288731e22d6ab6c7866d61b568b0d1b3";
          sha256 = "sha256-Xz49VlbgBS2oJHtuESOWzofx4MFoaS+P8S5k5e/m0m0=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = with pkgs; [ git gnumake zip ];
        buildInputs = with pkgs; [ SDL2 ];

        phases = [
          "unpackPhase"
          "patchPhase"
          "configurePhase"
          "buildPhase"
          "installPhase"
        ];
        
        buildPhase = "make";
        installPhase = ''
          mkdir -p $out/bin
          cp build/GameTankEmulator $out/bin
        '';
      };
    };
}

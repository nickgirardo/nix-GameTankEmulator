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
          rev = "a95641a904bb1e8c26c536a1a556b55321253be5";
          sha256 = "sha256-H7lO23KfbGgmohBobGNbAxFl1L7lA2NEOdGkYtAvPps=";
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
        
        buildPhase = "make bin";
        installPhase = ''
          mkdir -p $out/bin
          cp build/GameTankEmulator $out/bin
        '';
      };
    };
}

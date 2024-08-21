{
  description = "Emulator for the GameTank";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ system, pkgs, ... }: let
        gte_rev = "b9b11e311d4c0827e02284bfc5e62bc56cc9c6e9";
        src = pkgs.fetchgit {
          url = "https://github.com/clydeshaffer/GameTankEmulator.git";
          rev = gte_rev;
          sha256 = "sha256-kXd2oeac8Qo4HjdP3lBGZq9CV4dds1UW9uegVkW8NRE=";
          fetchSubmodules = true;
        };
        SDL2_rev = "release-2.28.4";
        SDL2 = pkgs.fetchzip {
          url = "https://github.com/libsdl-org/SDL/archive/${SDL2_rev}.zip";
          hash = "sha256-1+1m0s3pBCTu924J/4aIu4IHk/N88x2djWDEsDpAJn4=";
        };
        gte = pkgs.stdenv.mkDerivation {
          homepage = "https://github.com/clydeshaffer/GameTankEmulator";
          name = "GameTankEmulator";

          inherit src system;

          nativeBuildInputs = with pkgs; [ gnumake zip ];
          buildInputs = [ pkgs.SDL2 ];

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
        gte-web = pkgs.stdenv.mkDerivation {
          homepage = "https://github.com/clydeshaffer/GameTankEmulator";
          name = "GameTankEmulator-web";

          inherit src system;

          nativeBuildInputs = with pkgs; [
            emscripten
            gnumake
            zip
            unzip
          ];

          phases = [
            "unpackPhase"
            "patchPhase"
            "configurePhase"
            "buildPhase"
            "installPhase"
          ];

          # This value is meant to be overridden with the location to the rom the caller would like to bundle
          rom = "roms/hello.gtr";

          MANUAL_COMMIT_HASH = gte_rev;
          EMCC_LOCAL_PORTS = "sdl2=${SDL2}";
          ROMFILE = "roms/tmp/rom.gtr";

          buildPhase = ''
            mkdir -p $NIX_BUILD_TOP/cache

            mkdir -p roms/tmp
            cp $rom $ROMFILE

            EM_CACHE=$NIX_BUILD_TOP/cache OS=wasm make dist
          '';

          installPhase = ''
            mkdir -p $out/dist
            unzip dist/GTE_wasm.zip -d $out/dist
          '';
        };
      in {
        default = gte;
        inherit gte gte-web;
      });
    };
}

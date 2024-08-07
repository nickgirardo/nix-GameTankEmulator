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
        gte_rev = "0e8ec2feac9269ad1ac0df2b347bcb59b7e58b02";
        src = pkgs.fetchgit {
          url = "https://github.com/clydeshaffer/GameTankEmulator.git";
          rev = gte_rev;
          sha256 = "sha256-4hEYwrE56OdWjh8rlEzWOUn36gG8kEnR2N1GBoAaKrI=";
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

          MANUAL_COMMIT_HASH = gte_rev;
          EMCC_LOCAL_PORTS = "sdl2=${SDL2}";
          ROMFILE_SRC = "roms/hello.gtr";
          ROMFILE = "roms/hello_world.gtr";

          buildPhase = ''
            mkdir -p $NIX_BUILD_TOP/cache
            cp $ROMFILE_SRC $ROMFILE
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

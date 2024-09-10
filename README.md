## nix-GameTankEmulator

A Nix flake to for the [GameTank Emulator](https://github.com/clydeshaffer/GameTankEmulator).

This outputs two packages: the native emulator `gte` (which is default) and the web emulator `gte-web`.

`gte-web` can be overriden to create distributable web assets. For example, here is an excerpt from [AVHG's flake.nix](https://github.com/nickgirardo/gt-a-very-hard-game/blob/main/flake.nix):

```nix
web-emulator = GameTankEmulator.outputs.packages.${system}.gte-web.overrideAttrs (final: prev: {
  rom = "${avhg}/bin/game.gtr";
  WEB_SHELL = "${avhg}/web/shell.html";
  WEB_ASSETS = "${avhg}/web/assets/";
  WINDOW_TITLE = "A Very Hard Game";
});
```

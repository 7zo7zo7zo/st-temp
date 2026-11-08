{
  description = "A flake for my personal fork of suckless's dwm";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = lib.intersectLists lib.systems.flakeExposed lib.platforms.linux;
      forAllSystems = lib.genAttrs systems;

      overlays = [
        (final: prev: {
          dwm = prev.dwm.overrideAttrs (old: {
            src = ./.;
          });
        })
      ];

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system overlays;
        }
      );
    in
    {
      overlays.default = lib.composeManyExtensions overlays;

      packages = forAllSystems (
        system:
        {
          default = nixpkgsFor.${system}.dwm;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default =
            pkgs.mkShell {
              packages = with pkgs; [
                clang-tools
                codespell
                cppcheck
              ];

              inputsFrom = [
                pkgs.dwm
              ];
            };
        }
      );
    };
}

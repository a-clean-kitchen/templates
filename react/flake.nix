{
  description = "React Project";

  inputs = {
    nixpkgs.url = "nixpkgs";
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pname = (builtins.fromJSON (builtins.readFile ./package.json)).name;
      version = (builtins.fromJSON (builtins.readFile ./package.json)).version;
      buildInputs = with pkgs; [
        nodejs_20
        nodePackages_latest.pnpm
        typescript
      ];
      nativeBuildInputs = buildInputs;
      npmDepsHash = ""; # Find this value using `make depHashFetch`
    in rec {
      devShells.default = pkgs.mkShell {
        inherit buildInputs;
        shellHook = ''
          #!/usr/bin/env bash
        '';
      };
      
      # nix run
      apps.default = {
        type = "app";
        program = "${packages.default}/bin/${pname}";
      };

      # nix build
      packages.default = pkgs.buildNpmPackage {
        inherit pname version buildInputs npmDepsHash nativeBuildInputs;
        makeCacheWritable = true;
        __noChroot = true;
        src = ./.;
        postInstall = ''
          mkdir -p $out/bin
          exe="$out/bin/${pname}"
          lib="$out/lib"
          cp -r ./dist $lib
          touch $exe
          chmod +x $exe
          echo "
              #!/usr/bin/env bash
              cd $lib/dist
              ${pkgs.python3}/bin/python3 -m http.server" > $exe
        '';
      };
    });
}



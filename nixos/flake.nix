{
  description = "I Use NixosBtw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    matugen.url = "github:InioX/Matugen";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rmpc = {
      url = "github:mierak/rmpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # nix4nvchad = {
    #   url = "github:nix-community/nix4nvchad";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # dev shells
    devShells.${system}.quickcli = import ./devshell/quickcli.nix {inherit pkgs;};

    # system config
    nixosConfigurations.nixosBtw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {inherit inputs;};

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs;};
            users.dfltplyr = import ./users/home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}

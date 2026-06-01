{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen.url = "github:InioX/Matugen";
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
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Make sure '@inputs' is present right here 👇
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
    nixosConfigurations.nixosBtw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # This passes inputs to configuration.nix
      specialArgs = {inherit inputs;};

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # 👇 THIS EXACT LINE PLACED RIGHT HERE FIXES THE ERROR 👇
            extraSpecialArgs = {inherit inputs;};

            users.dfltplyr = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nix-darwin.url = "github:lnl7/nix-darwin";
  };

  outputs = inputs: let
    lib = import ../lib {inherit (inputs.nixpkgs) lib;};
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
  in rec {
    nixosConfigurations = {
      "nixos-server" = lib.mkSystem {
        ren = {
          system = "aarch64-linux";
          inherit pkgs;
          inherit (inputs) home-manager disko;
        };

        networking.hostName = "nixos-server";
        users.users."demo" = {
          home = "/home/demo";
          isNormalUser = true;
          group = "example";
        };
        users.groups."example" = {};

        disko.devices = pkgs.lib.mkMerge [
          diskoConfigurations.some-disk.innerConfig
        ];

        home-manager = {
          useUserPackages = false;
          useGlobalPkgs = true;
          users.demo = homeConfigurations."demo-standalone".innerConfig;
        };
      };

      "nixos-wsl" = lib.mkSystem {
        ren = {
          system = "x86_64-linux";
          inherit pkgs;
          inherit (inputs) nixos-wsl;
        };

        wsl.defaultUser = "demo";
      };
    };

    darwinConfigurations = {
      "my-macbook" = lib.mkSystem {
        ren = {
          system = "aarch64-darwin";
          inherit pkgs;
          inherit (inputs) nix-darwin;
        };
        system.stateVersion = 6;
        users.users.demo.home = "/Users/demo";
      };
    };

    diskoConfigurations = {
      "some-disk" = lib.mkDisk {
        disk = {
          sda = {
            device = "/dev/sda";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  size = "1M";
                  type = "EF02";
                  attributes = [0];
                };
                root = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
        ren = {
          inherit pkgs;
          inherit (inputs) disko;
        };
      };
    };

    homeConfigurations = {
      "demo-standalone" = lib.mkHome {
        ren = rec {
          system = "x86_64-linux";
          inherit (inputs) home-manager;
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
        home = {
          username = "demo";
          homeDirectory = "/home/demo";
          stateVersion = "23.11";
        };
      };
    };
  };
}

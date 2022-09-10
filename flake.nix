{
  description = "It makes Images";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

    dump-dvb = {
      url = github:dump-dvb/dump-dvb.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ddvb-deployment = {
      url = github:dump-dvb/nix-config;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , dump-dvb
    , ddvb-deployment
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;

      hosts = [
        "user-radio"
      ];

      devices = [
        {
          arch = "aarch64-linux";
          name = "rpi3";
        }
        {
          arch = "aarch64-linux";
          name = "rpi4";
        }
        {
          arch = "x86_64-linux";
          name = "dell-wyse-3040";
        }
      ];

      systems = lib.cartesianProductOfSets { host = hosts; device = devices; };
      generate_system = (host: arch: device: {
        "${host}-${arch}-${device}" = nixpkgs.lib.nixosSystem
          {
            system = arch;
            specialArgs = {
              inherit inputs;
              diskModule = inputs.dump-dvb.nixosModules.disk-module;
              rpiHwConfig = "${inputs.ddvb-deployment}/hardware/rpi-3b-4b.nix";
              dellHwConfig = "${inputs.ddvb-deployment}/hardware/dell-wyse-3040.nix";
            };
            modules = [
              dump-dvb.nixosModules.default
              ./modules/${host}
              ./modules/device-specific/${device}
              ./user-config
              {
                nixpkgs.overlays = [
                  dump-dvb.overlays.default
                ];
                networking.hostName = lib.mkForce "${host}-${arch}-${device}";
              }
            ];
          };
      }
      );

      system_configs = lib.foldl (x: y: lib.mergeAttrs x (generate_system y.host y.device.arch y.device.name)) { } systems;

      packages_vms = lib.foldl (x: y: lib.mergeAttrs x { "${y.config.system.name}-vm" = y.config.system.build.vm; }) { } (lib.attrValues system_configs);

      packages_img_x86 = lib.foldl (x: y: lib.mergeAttrs x { "${y.config.system.name}-image" = y.config.system.build.diskImage; }) { } (lib.filter (x: x.config.system.build.toplevel.system == "x86_64-linux") (lib.attrValues system_configs));
      packages_img_aarch64 = lib.foldl (x: y: lib.mergeAttrs x { "${y.config.system.name}-image" = y.config.system.build.sdImage; }) { } (lib.filter (x: x.config.system.build.toplevel.system == "aarch64-linux") (lib.attrValues system_configs));
    in
    {
      nixosConfigurations = system_configs;

      packages."x86_64-linux" = packages_vms // packages_img_x86 // packages_img_aarch64;

      hydraJobs = (lib.mapAttrs (k: v: { "x86_64-linux" = v; }) (packages_img_x86)) //
                  (lib.mapAttrs (k: v: { "aarch64-linux" = v; }) (packages_img_aarch64));
    };
}

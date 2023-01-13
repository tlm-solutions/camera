{
  description = "It makes Images";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    tlms = {
      url = "github:tlm-solutions/tlms.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , tlms
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;

      hosts =
        let
          hosts = [
            "user_radio"
            "mobile_box_dresden"
            "mobile_box_chemnitz"
            "mobile_box_berlin"
            "mobile_box_hannover"
          ];
        in
        map (x: assert lib.assertMsg (!(lib.hasInfix "-" x)) "hosts string cannot contain -"; x) hosts;

      devices =
        let
          devices = [
            {
              arch = "aarch64-linux";
              name = "Raspberry_Pi_3B";
            }
            {
              arch = "aarch64-linux";
              name = "Raspberry_Pi_4";
            }
            {
              arch = "x86_64-linux";
              name = "Dell_Wyse_3040";
            }
          ];
        in
        map (x: assert lib.assertMsg (!(lib.hasInfix "-" x.name)) "device name cannot contain '-'"; x) devices;

      systems = lib.cartesianProductOfSets { host = hosts; device = devices; };
      generate_system = (host: arch: device: {
        "${host}-${device}" = nixpkgs.lib.nixosSystem
          {
            system = arch;
            specialArgs = {
              inherit inputs;
              diskModule = inputs.tlms.nixosModules.disk-module;
            };
            modules = [
              tlms.nixosModules.default
              ./modules/${host}
              ./modules/device-specific/${device}
              ./user-config
              {
                nixpkgs.overlays = [
                  tlms.overlays.default
                ];
                networking.hostName = lib.mkForce "${host}-${device}";
                # adjust this variable to the nixpkgs version defined in the inputs
                system.stateVersion = lib.mkDefault "22.05";
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

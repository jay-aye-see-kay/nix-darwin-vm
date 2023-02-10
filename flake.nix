{
  outputs = { self, nixpkgs }: {

    nixosModules.base = { pkgs, ... }: {
      system.stateVersion = "22.05";
      # Configure networking
      networking.useDHCP = false;
      networking.interfaces.eth0.useDHCP = true;
      # Create user "test"
      services.getty.autologinUser = "test";
      users.users.test.isNormalUser = true;
      # Enable passwordless ‘sudo’ for the "test" user
      users.users.test.extraGroups = [ "wheel" ];
      security.sudo.wheelNeedsPassword = false;
    };

    nixosModules.vm = _: {
      # Make VM output to the terminal instead of a separate window
      virtualisation.vmVariant.virtualisation.graphics = false;
    };

    nixosConfigurations.darwinVM = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        self.nixosModules.base
        # self.nixosModules.vm
        { virtualisation.vmVariant.virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin; }
      ];
    };
    packages.aarch64-darwin.darwinVM = self.nixosConfigurations.darwinVM.config.system.build.vm;

  };
}


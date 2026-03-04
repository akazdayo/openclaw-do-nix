{
  self,
  nixpkgs,
  nix-openclaw,
  sops-nix,
  ...
}:
{
  droplet = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit self; };
    modules = [
      "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix"
      { nixpkgs.overlays = [ nix-openclaw.overlays.default ]; }
      nix-openclaw.nixosModules.openclaw-gateway
      sops-nix.nixosModules.sops
      self.modules.dropletConfiguration
      self.modules.openclawConfiguration
    ];
  };
}

{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/openclaw.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;

    secrets."openclaw.env" = {
      restartUnits = [ "openclaw-gateway.service" ];
    };
  };

  services.openclaw-gateway = {
    enable = true;
    port = 18789;
    environmentFiles = [
      config.sops.secrets."openclaw.env".path
    ];
  };

  networking.firewall.allowedTCPPorts = [ 18789 ];
}

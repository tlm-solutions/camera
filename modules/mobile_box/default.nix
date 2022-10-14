{ lib, pkgs, config, ... }:
{
  dump-dvb = {
    gnuradio = {
      enable = true;
      device = "";
      RF = 14;
      IF = 32;
      BB = 42;
    };
    telegramDecoder = {
      enable = true;
      server = [ "http://127.0.0.1:8080" ];
      offline = true;
    };
  };

  dump-dvb.wartrammer.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 config.dump-dvb.wartrammer.port ];

  systemd.services."start-wifi-hotspot" = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      ${pkgs.linux-router}/bin/lnxrouter --ap wlan0 dump-dvb -g 10.3.141.1 -p trolling-dvb
    '';
  };

  # make sure wifi interface is called wlan0
  networking.usePredictableInterfaceNames = lib.mkForce false;
}

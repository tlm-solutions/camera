{ lib, pkgs, config, ... }:
{
  TLMS = {
    gnuradio = {
      enable = true;
      device = "";
      RF = 14;
      IF = 32;
      BB = 42;
    };
    telegramDecoder = {
      enable = true;
      server = [ "http://127.0.0.1:${toString config.TLMS.wartrammer.port}" ];
      offline = true;
      configFile = pkgs.writeScript "config.json" ''
        {
            "name": "Mobile",
            "lat": 0,
            "lon": 0,
            "id": "00000000-0000-0000-0000-000000000000",
            "region": ${toString config.TLMS.wartrammer.region}
        }
      '';
    };
    wartrammer.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 config.TLMS.wartrammer.port ];

  hardware = {
    hackrf.enable = true;
    rtl-sdr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    rtl-sdr
    hackrf
    usbutils
    tcpdump
    nmap
    tmux
    neovim
    git
  ];

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

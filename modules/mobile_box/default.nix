{ lib, pkgs, config, ... }:
{
  options.dump-dvb.telegramDecoder.region = with lib; mkOption {
    type = types.int;
    default = -1;
    description = "Region of the current mobile box.";
  };

  config = {
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
        configFile = pkgs.writeScript "config.json" ''
          {
              "name": "Mobile",
              "lat": 0,
              "lon": 0,
              "id": "00000000-0000-0000-0000-000000000000",
              "region": ${toString config.dump-dvb.telegramDecoder.region}
          }
        '';
      };
      wartrammer.enable = true;
    };

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
  };
}

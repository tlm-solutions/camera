{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  dump-dvb = {
    gnuradio = {
      frequency = 153850000;
      offset = 20000;
    };
    telegramDecoder.region = 1;
  };
}

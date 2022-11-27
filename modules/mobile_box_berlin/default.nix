{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  dump-dvb = {
    # 170.45MHz + 5kHz offset for hackrf...
    gnuradio = {
      frequency = 170435000;
      offset = 20000;
    };
    wartrammer.region = 2;
  };
}

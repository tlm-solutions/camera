{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  dump-dvb = {
    # 150.91MHz + 5kHz offset for hackrf...
    gnuradio = {
      frequency = 150915000;
      offset = 20000;
    };
    wartrammer.region = 4; # Hannover
  };
}

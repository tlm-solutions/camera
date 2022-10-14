{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  dump-dvb = {
    gnuradio = {
      frequency = 170795000;
      offset = 19550;
    };
    telegramDecoder.region = 0;
  };
}

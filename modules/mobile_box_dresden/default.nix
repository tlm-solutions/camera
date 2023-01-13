{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  TLMS = {
    gnuradio = {
      frequency = 170795000;
      offset = 19550;
    };
    wartrammer.region = 0;
  };
}

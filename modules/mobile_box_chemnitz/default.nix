{ pkgs, config, ... }:
{
  imports = [
    ../mobile_box/default.nix
  ];

  TLMS = {
    gnuradio = {
      frequency = 153850000;
      offset = 20000;
    };
    wartrammer.region = 1;
  };
}

{ lib, config, pkgs, ... }:
{
  imports = [
    ./user.nix
    ./grow-root.nix
  ];

  # Any settings you wish to change should go here, /modules will be overwritten on update

  ## Set Radio Parameters
  #dump-dvb.gnuradio = {
  #  frequency = ;
  #  offset = ;
  #  device = ;
  #  RF = ;
  #  IF = ;
  #  BB = ;
  #};
}

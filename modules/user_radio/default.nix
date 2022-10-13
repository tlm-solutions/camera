{ lib, ... }: {
  dump-dvb.gnuradio = lib.mkDefault {
    # by default - Dresden RTL-SDR config
    enable = true;
    frequency = 170790000;
    offset = 20000;
    device = "";
    RF = 14;
    IF = 32;
    BB = 42;
  };

  dump-dvb.telegramDecoder = lib.mkDefault {
    enable = true;
    server = [ "http://10.13.37.1:8080" "http://10.13.37.5:8080" ];
  };
}

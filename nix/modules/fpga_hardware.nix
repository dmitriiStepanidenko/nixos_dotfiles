# Apps and Packages for fpga and etc
{
  config,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.system;
  unstable = import inputs.nixos-unstable {
    inherit system;
    config = {
      allowUnfree = true;
      #permittedInsecurePackages = [
      #  "electron-27.3.11"
      #];
    };
  };
in {
  environment.systemPackages = with pkgs; [
    gtkwave
    iverilog # icarus verilog
    verilator

    systemc
    ghdl
    logisim-evolution
    qucs-s

    yosys
    #unstable.yosys-synlig
    yosys-ghdl
    netlistsvg
    mcy
    sby
    boolector
    btor2tools
    z3

    #kicad

    openhantek6022

    unstable.surfer

    openfpgaloader
  ];

  services = {
    udev = {
      extraRules = ''
        # rules for OpenHantek6022 (DSO program) as well as Hankek6022API (python tools)
        ACTION!="add|change", GOTO="openhantek_rules_end"
        SUBSYSTEM!="usb|usbmisc|usb_device", GOTO="openhantek_rules_end"
        ENV{DEVTYPE}!="usb_device", GOTO="openhantek_rules_end"

        # Hantek DSO-6022BE, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Instrustar isds-205b, without FW, with FW
        ATTRS{idVendor}=="d4a2", ATTRS{idProduct}=="5661", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="1d50", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Hantek DSO-6022BL, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Voltcraft DSO-2020, without FW (becomes DSO-6022BE when FW is uploaded)
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2020", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # BUUDAI DDS120, without FW, with FW
        ATTRS{idVendor}=="8102", ATTRS{idProduct}=="8102", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="0120", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # Hantek DSO-6021, without FW, with FW
        ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        # YiXingDianZiKeJi MDSO, without FW, with FW
        ATTRS{idVendor}=="d4a2", ATTRS{idProduct}=="5660", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
        ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608e", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

        LABEL="openhantek_rules_end"

        SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="plugdev"
        # Tang Nano 20K (Gowin GW2A) — USB-JTAG
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", GROUP="plugdev", MODE="0660"
        # Tang Nano 9K / other variants (different PID)
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", GROUP="plugdev", MODE="0660"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", GROUP="plugdev", MODE="0660"
        SUBSYSTEM=="usb_device", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", GROUP="plugdev", MODE="0660"

        # FTDI USB-JTAG/UART for ALL FPGA dev boards (Tang Nano, TinyFPGA, etc.)
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", GROUP="plugdev", MODE="0660"

        SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666"
      '';
    };
  };
}

{
  lib,
  stdenv,
  python3,
  zlib,
  pkg-config,
  glib,
  perl,
  texinfo,
  libuuid,
  flex,
  bison,
  pixman,
  meson,
  fetchFromGitHub,
  ninja,
}:

let
  qemuName = "qemu-5.2.50";
in
stdenv.mkDerivation {
  name = "aflplusplus-${qemuName}";

  src = fetchFromGitHub {
    owner = "AFLplusplus";
    repo = "qemuafl";
    # Use a fixed qemuafl version instead of the one in https://github.com/AFLplusplus/AFLplusplus/blob/v4.31c/qemu_mode/QEMUAFL_VERSION.
    # See: https://github.com/AFLplusplus/AFLplusplus/issues/2296.
    rev = "ef1cd9a8cb1522c918faab42805216f9a4054dda";
    hash = "sha256-tbKDnDoBtFhvtE9nbi9XuHPuFuGezUFngnw4pJyKFgY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python3
    perl
    pkg-config
    flex
    bison
    meson
    texinfo
    ninja
  ];

  buildInputs = [
    zlib
    glib
    pixman
    libuuid
  ];

  enableParallelBuilding = true;

  dontUseMesonConfigure = true; # meson's configurePhase isn't compatible with qemu build
  preBuild = "cd build";
  preConfigure = ''
    # this script isn't marked as executable b/c it's indirectly used by meson. Needed to patch its shebang
    chmod +x ./scripts/shaderinclude.pl
    patchShebangs .
  '';

  configureFlags = [
    "--target-list=${stdenv.hostPlatform.uname.processor}-linux-user"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--meson=meson"
    "--disable-system"
    "--enable-linux-user"
    "--enable-pie"
    "--audio-drv-list="
    "--disable-blobs"
    "--disable-bochs"
    "--disable-brlapi"
    "--disable-bsd-user"
    "--disable-bzip2"
    "--disable-cap-ng"
    "--disable-cloop"
    "--disable-curl"
    "--disable-curses"
    "--disable-dmg"
    "--disable-fdt"
    "--disable-gcrypt"
    "--disable-glusterfs"
    "--disable-gnutls"
    "--disable-gtk"
    "--disable-guest-agent"
    "--disable-iconv"
    "--disable-libiscsi"
    "--disable-libnfs"
    "--disable-libssh"
    "--disable-libusb"
    "--disable-linux-aio"
    "--disable-live-block-migration"
    "--disable-lzo"
    "--disable-nettle"
    "--disable-numa"
    "--disable-opengl"
    "--disable-parallels"
    "--disable-plugins"
    "--disable-qcow1"
    "--disable-qed"
    "--disable-rbd"
    "--disable-rdma"
    "--disable-replication"
    "--disable-sdl"
    "--disable-seccomp"
    "--disable-sheepdog"
    "--disable-smartcard"
    "--disable-snappy"
    "--disable-spice"
    "--disable-system"
    "--disable-tools"
    "--disable-tpm"
    "--disable-usb-redir"
    "--disable-vde"
    "--disable-vdi"
    "--disable-vhost-crypto"
    "--disable-vhost-kernel"
    "--disable-vhost-net"
    "--disable-vhost-scsi"
    "--disable-vhost-user"
    "--disable-vhost-vdpa"
    "--disable-vhost-vsock"
    "--disable-virglrenderer"
    "--disable-virtfs"
    "--disable-vnc"
    "--disable-vnc-jpeg"
    "--disable-vnc-png"
    "--disable-vnc-sasl"
    "--disable-vte"
    "--disable-vvfat"
    "--disable-xen"
    "--disable-xen-pci-passthrough"
    "--disable-xfsctl"
    "--without-default-devices"
  ];

  meta = {
    homepage = "https://github.com/AFLplusplus/qemuafl";
    description = "Fork of QEMU with AFL++ instrumentation support";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      ris
      msanft
    ];
    platforms = lib.platforms.linux;
  };
}

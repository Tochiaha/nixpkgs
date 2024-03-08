{ lib
, stdenvNoCC
, libsForQt5
, fetchFromGitLab
, autoreconfHook
, libtool
, pkg-config
, zlib
, openssl
, freetype
, fontconfig
, gcc
, expat
, cmake
}:

stdenvNoCC.mkDerivation rec {
  pname = "ophcrack";
  version = "3.8.0-3";

  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "pkg-security-team";
    repo = "ophcrack";
    rev = "debian/${version}";
    hash = "sha256-94zEr7aBeqMjy5Ma50W3qv1S5yx090bYuTieoZaXFcc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libtool
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    pkg-config
    zlib
    openssl
    freetype
    fontconfig
    libsForQt5.qtcharts
    gcc
    expat
  ];

  dontWrapQtApps = true;

  configureFlags = [
    "--with-libssl=yes --disable-gui"
  ];

  env.CFLAGS = toString [
    "-I/usr/include/libxml2/libxml"
  ];

  buildPhase = ''
    make
  '';

  postBuild = ''
    wrapQtApp "$out/bin/$src"
      --prefix PATH : "${libsForQt5.qtbase}/bin/"
  '';

  postInstall = ''
    mv $out/bin/ophcrack $out/bin/ophcrack-cli
  '';

  meta = with lib; {
    description = "Password crack based on the faster time-memory trade-off. With MySQL and Cisco PIX Algorithm patches";
    homepage = "https://ophcrack.sourceforge.io";
    changelog = "https://salsa.debian.org/pkg-security-team/ophcrack/-/blob/${src.rev}/ChangeLog";
    license = with licenses; [ gpl2Plus ];
    maintainers = with maintainers; [ tochiaha ];
    mainProgram = "ophcrack-cli";
    platforms = platforms.all;
  };
}

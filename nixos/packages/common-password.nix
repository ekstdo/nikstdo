{ stdenv, lib, fetchurl, gzip }:
stdenv.mkDerivation rec {
  name = "rockyou-txt-${version}";
  version = "1.0";

  unpackCmd = "gunzip -c \"$curSrc\" > rockyou.txt";
  sourceRoot = "."; # use this, when archive doesn't create a directory and you get the: unpacker appears to have produced no directories -error
  src = fetchurl {
    url = "https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz";
    sha256 = "sha256-3tLZYoFeElbfjzoNJRc8SyG27uY2EXw2mZJGclptj58=";
  };

  nativeBuildInputs = [ gzip ];
  buildInputs = [ ];


  installPhase = ''
    mkdir -p $out/share/rockyou/
    cp rockyou.txt $out/share/rockyou/
  '';
  pathsToLink = ["/share"];
}


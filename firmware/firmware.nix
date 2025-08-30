#<<< TODO: should this just be a nixos module instead that sets `hardware.firmware = [ mt7996-firmware ]` ? >>>
{ pkgs, ... }:
let
  mt76-owrt = pkgs.fetchFromGitHub {
    owner = "openwrt";
    repo = "mt76";
    rev = "32ca2b6db354db090eb306e9f5b85651e92dfa8b"; # <<< is this magical? should it be a flake input? >>>
    hash = "sha256-X2FfiCkRVSzBWTltGKprIPJha+qV9Kg8+41l56NCGbs=";
  };
in
pkgs.runCommand "mt7996-firmware" { } ''
  mkdir -p $out/lib/firmware/mediatek/
  cp -r ${mt76-owrt}/firmware/mt7996/ $out/lib/firmware/mediatek/
''

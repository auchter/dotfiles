{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.brutefir;
  genConfig = input: pkgs.callPackage ({ python-brutefir }: pkgs.stdenv.mkDerivation {
    name = "brutefir-config";
    nativeBuildInputs = [ python-brutefir ];
    buildCommand = ''
      brutefir-gen-config ${input} --output $out
    '';
  }) { };
  attrSetToList = mapAttrsToList (name: attrs: attrs // { name = name; });
in {
  options.modules.brutefir = {
    enable = mkEnableOption "brutefir";

    # TODO: Should perform more validation instead of relying on brutefir-gen-config
    samplingRate = mkOption {
      default = 44100;
    };

    floatBits = mkOption {
      default = 32;
    };

    resampleCoeffs = mkOption {
      default = true;
    };

    cliPort = mkOption {
      default = 6556;
      type = types.port;
    };

    filterLength = mkOption {
      default = "4096, 32";
    };

    inputs = mkOption { };
    outputs = mkOption { };
    filters = mkOption { };
    coeffs = mkOption { };
  };

  config = mkIf cfg.enable {
    modules.snapclient.brutefirConfig = genConfig (pkgs.writeText "brutefir.yml" (generators.toYAML {} {
      sampling_rate = cfg.samplingRate;
      float_bits = cfg.floatBits;
      resample_coeffs = cfg.resampleCoeffs;
      cli_port = cfg.cliPort;
      filter_length = cfg.filterLength;
      inputs = attrSetToList cfg.inputs;
      outputs = attrSetToList cfg.outputs;
      filters = attrSetToList cfg.filters;
      coeffs = attrSetToList cfg.coeffs;
    })) + "/brutefir_config";
  };
}

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  modules.sshd.enable = true;
  modules.interactive.enable = true;

  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
  ];

  # audio stuff
  boot.kernelModules = [ "snd-aloop" ];
  
  services.pipewire.systemWide = true;

  # TODO: migrate to extraConfig!
  environment.etc = {
    "pipewire/pipewire.conf.d/pipewire.conf".text = ''
      context.properties = {
        default.clock.rate = 96000
      }
      context.objects = [
	{ factory = adapter
          args = {
              factory.name     = api.alsa.pcm.sink
              node.name        = "camilladsp-sink"
              node.description = "Alsa Loopback"
              media.class      = "Audio/Sink"
              api.alsa.path    = "hw:Loopback,0,0"
              audio.format     = "S32LE"
              audio.rate       = 96000
              audio.channels   = 2
              priority.session = 1400
          }
	}
      ]
    '';
  };
  systemd.services.pipewire.restartTriggers = [
    config.environment.etc."pipewire/pipewire.conf.d/pipewire.conf".text
  ];

  # EQ
  services.camilladsp.enable = true;
  services.camillagui = {
    enable = true;
    openFirewall = true;
    port = 5000;
  };
  services.mpdcamillamixer.enable = true;

  # MPD
  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/storage/music";
    playlistDirectory = "/mnt/storage/music/playlists";
    network = {
      listenAddress = "any";
    };
    extraConfig = ''
      resampler {
        plugin "libsamplerate"
        type "0"
      }
      auto_update "yes"
      replaygain "auto"
      audio_output {
        type    "fifo"
        name    "snapcast"
        path    "/run/snapserver/mpd"
        format  "44100:16:2"
        mixer_type "null"
      }
      audio_output {
        type "pipewire"
        name "Pipewire"
        mixer_type "null"
      }
    '';
  };
  systemd.services.mpd.serviceConfig.restart = "always";
  users.users.mpd.extraGroups = [ "audio" "pipewire" ];

  modules.upmpdcli.enable = true;

  # Snapcast
  services.snapserver = {
    enable = true;
    openFirewall = true;
    http.docRoot = "${pkgs.snapcast}/share/snapserver/snapweb";
    streams = {
      mpd = {
        type = "pipe";
        location = "/run/snapserver/mpd";
        query = {
          mode = "create";
          sampleformat = "44100:16:2";
          codec = "ogg";
        };
      };
    };
  };

  # end audiostuff

  system.stateVersion = "23.11"; # Did you read the comment?
}


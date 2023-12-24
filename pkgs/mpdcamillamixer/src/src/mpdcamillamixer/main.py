import asyncio
import argparse
import logging
from mpd.asyncio import MPDClient
from camilladsp import CamillaConnection, CamillaError

logging.basicConfig(level="INFO")
_LOGGER = logging.getLogger(__name__)

# Map percentage to dB, from -50 to 0 in 0.5dB steps
def default_scale(pct):
    return pct * 0.5 - 50


class CamillaDSPVolume:
    def __init__(self, host, port, scale=default_scale):
        self.cdsp = CamillaConnection(host, port)
        self.scale = scale
        self.cdsp.connect()
        self.cdsp.disconnect()

    def set_volume(self, pct):
        assert pct >= 0
        assert pct <= 100
        db = self.scale(pct)

        for i in range(2):
            if not self.cdsp.is_connected():
                self.cdsp.connect()

            try:
                self.cdsp.set_volume(db)
                return
            except Exception as e:
                _LOGGER.info(f"set_volume failed, {e}, retrying")
                continue

    def set_config(self, config):
        for i in range(2):
            if not self.cdsp.is_connected():
                self.cdsp.connect()

            try:
                # TODO: Need to figure out what I want here...
                return
            except Exception as e:
                _LOGGER.info(f"set_config failed, {e}, retrying")
                continue


class TurntableState:
    def __init__(self, cdsp):
        self.cdsp = cdsp
        self.turntable_config = False

    def enabled(self):
        return self.turntable_config

    def enable(self):
        self.cdsp.set_config('_turntable')
        self.turntable_config = True

    def disable(self):
        self.cdsp.set_config('_default')
        self.turntable_config = False

    def handle(self, msg):
        if not self.enabled():
            if msg == 'spinning':
                self.enable()
                return
        if self.enabled():
            if msg == 'off':
                self.disable()


async def controller(host, port, cdsp):
    client = MPDClient()
    tt = TurntableState(cdsp)

    while True:
        await client.connect(host, port)
        await client.subscribe("turntable")
        async for subsystem in client.idle(['mixer', 'message']):
            messages = await client.readmessages()
            for message in messages:
                if message['channel'] == 'turntable':
                    tt.handle(message['message'])

            status = await client.status()
            vol = int(status['volume'])
            cdsp.set_volume(vol)

def main():
    parser = argparse.ArgumentParser(description="mpdcamillamixer")
    parser.add_argument('--mpd-host', default='localhost', help="Host of MPD server")
    parser.add_argument('--mpd-port', default=6600, type=int, help='MPD port')
    parser.add_argument('--camilla-host', default='localhost', help='CamillaDSP host')
    parser.add_argument('--camilla-port', default=5000, type=int, help='CamillaDSP websocket port')
    args = parser.parse_args()

    cdsp = CamillaDSPVolume(args.camilla_host, int(args.camilla_port))
    asyncio.run(controller(args.mpd_host, int(args.mpd_port), cdsp))

if __name__ == '__main__':
    main()

from powermate import Powermate, PowermateDelegate
import logging
from mpd import MPDClient, ConnectionError
from socket import error as SocketError
import argparse

class PowermateMPD(PowermateDelegate):
    def __init__(self, mpd):
        self.mpd = mpd
        self.last_battery = None

    def on_battery_report(self, val):
        if self.last_battery != val:
            logging.warning(f"battery level: {val}%")
            self.last_battery = val

    def on_connect(self):
        self.mpd.connect()

    def on_disconnect(self):
        self.mpd.disconnect()

    def on_clockwise(self):
        self.mpd.volume(1)

    def on_counterclockwise(self):
        self.mpd.volume(-1)

    def on_press(self):
        self.mpd.pause()


class MPD:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.client = MPDClient()
        self.connected = False

    def connect(self):
        if not self.connected:
            self.client.connect(host=self.host, port=self.port)
            self.connected = True

    def disconnect(self):
        if self.connected:
            self.client.disconnect()
            self.connected = False

    def _try_reconnect(self, func):
        try:
            func()
        except ConnectionError as e:
            logging.warning("command failed, reconnecting...")
            self.disconnect()
            self.connect()
            try:
                func()
            except Exception as e:
                logging.error(f"unable to run command... {e}")

    def volume(self, val):
        self._try_reconnect(lambda: self.client.volume(val))

    def pause(self):
        self._try_reconnect(lambda: self.client.pause())


def main():
    parser = argparse.ArgumentParser(description="mpdpower")
    parser.add_argument('--mpd-host', default='localhost', help="Host of MPD server")
    parser.add_argument('--mpd-port', default=6600, type=int, help='MPD port')
    parser.add_argument('addr', help="BT address of Griffin Powermate")
    args = parser.parse_args()

    mpd = MPD(args.mpd_host, args.mpd_port)
    delegate = PowermateMPD(mpd)
    power = Powermate(args.addr, delegate)

if __name__ == '__main__':
    main()

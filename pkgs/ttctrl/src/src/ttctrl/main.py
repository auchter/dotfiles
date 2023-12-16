#!/usr/bin/env python3

from pathlib import Path
from collections import deque
from enum import Enum, auto
import time
import logging
from pipewire_python import link
from pipewire_python.link import StereoInput, StereoOutput
from mpd import MPDClient, ConnectionError
import argparse

class Ina260:
    def __init__(self, path):
        self.path = Path(path)

    def get_power(self):
        f = self.path / "power1_input"
        return float(f.read_text()) / 1e6


def find_hwmon_by_name(name):
    for h in Path("/sys/class/hwmon/").glob("hwmon*"):
        if (h / "name").read_text().strip() == name:
            return h


class WindowedAverage:
    def __init__(self, wsize=16):
        self.wsize = int(wsize)
        self.sum = 0
        self.buffer = deque([])

    def add(self, sample):
        self.sum += sample
        self.buffer.append(sample)
        if len(self.buffer) > self.wsize:
            self.sum -= self.buffer.popleft()

    def get_average(self):
        if len(self.buffer) == 0:
            return None
        return self.sum / float(len(self.buffer))


class TurntableState(str, Enum):
    Off = auto()
    On = auto()
    Spinning = auto()


def find_endpoints(typ, device, name):
    # meh, assumes Stereo...
    def match(e):
        if e.right.device != device:
            return False
        if name not in e.right.name:
            return False
        return True

    endpoints = []
    for inp in link.list_inputs():
        if isinstance(inp, typ) and match(inp):
                endpoints.append(inp)
    for out in link.list_outputs():
        if isinstance(out, typ) and match(out):
            endpoints.append(out)

    return endpoints


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
        self.connect()
        try:
            func()
        except ConnectionError as e:
            logging.warning("Got connection error...")
            self.disconnect()
            self.connect()
            try:
                func()
            except Exception as e:
                logging.error(f"mpd command failed {e}")

    def pause(self):
        self._try_reconnect(lambda: self.client.pause(1))

    def sendmessage(self, channel, text):
        self._try_reconnect(lambda: self.client.sendmessage(channel, text))


class Controller:
    def __init__(self, sink_name, source_name, mpd_host, mpd_port):
        self.mpd = MPD(mpd_host, mpd_port)
        self.sink_name = sink_name
        self.source_name = source_name
        self.dispatch = {
            TurntableState.Off: self.off,
            TurntableState.On: self.on,
            TurntableState.Spinning: self.spinning,
        }
        self.source = None

    def do_pipewire(self):
        if self.sink_name is None:
            return False
        if self.source_name is None:
            return False
        return True

    def control(self, state):
        self.dispatch[state]()
        self.notify_mpd(state)

    def notify_mpd(self, state):
        msg = {
            TurntableState.Off: "off",
            TurntableState.On: "on",
            TurntableState.Spinning: "spinning",
        }
        try:
            self.mpd.sendmessage("turntable", msg[state])
        except Exception as e:
            logging.error(f"failed to send state message to mpd: {e}")

    def on(self):
        self.unlink()
    
    def off(self):
        self.unlink()

    def spinning(self):
        self.link()

    def link(self):
        try:
            self.mpd.pause()
        except Exception as e:
            logging.error(f"failed to pause mpd: {e}")

        if self.do_pipewire():
            self.sink = find_endpoints(StereoInput, self.sink_name, 'playback')[0]
            self.source = find_endpoints(StereoOutput, self.source_name, 'capture')[0]
            self.source.connect(self.sink)
            print("linked!")

    def unlink(self):
        if self.do_pipewire():
            if self.source is not None:
                self.source.disconnect(self.sink)
                self.source = None
                self.sink = None
                print("unlinked!")


def loop(cb=lambda x: None):
    freq = 20.0
    p = find_hwmon_by_name("ina260")
    i = Ina260(p)
    w = WindowedAverage(1 * freq)

    state = TurntableState.Off

    while True:
        p = i.get_power()
        w.add(p)
        power = w.get_average()

        next_state = state
        if state == TurntableState.Off:
            if power > 1.0:
                next_state = TurntableState.On
                time.sleep(0.8)  # wait for initial spike to settle
        elif state == TurntableState.On:
            if power > 1.7:
                next_state = TurntableState.Spinning
            elif power < 0.9:
                next_state = TurntableState.Off
        elif state == TurntableState.Spinning:
            if power < 1.4:
                next_state = TurntableState.On
            elif power < 0.9:
                next_state = TurntableState.Off

        if state != next_state:
            print(next_state, round(power, 2))
            cb(next_state)

        state = next_state
        time.sleep(1 / freq)


def main():
    parser = argparse.ArgumentParser(description="ttctrl")
    parser.add_argument('--mpd-host', default='localhost', help="Host of MPD server")
    parser.add_argument('--mpd-port', default=6600, type=int, help="MPD Port")
    parser.add_argument('--source-dev', default=None, help="name of the audio source")
    parser.add_argument('--sink-dev', default=None, help="name of the audio sink")
    args = parser.parse_args()

    ctrl = Controller(
        sink_name=args.sink_dev,
        source_name=args.source_dev,
        mpd_host=args.mpd_host,
        mpd_port=args.mpd_port)
    loop(ctrl.control)


if __name__ == '__main__':
    main()

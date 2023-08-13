#!/usr/bin/env python3

import argparse
import gpiod
import logging
import sys

logging.basicConfig(level="INFO")
_LOGGER = logging.getLogger(__name__)

class Amplifier:
    def __init__(self, gpio):
        self.line = gpiod.find_line(gpio)
        if self.line is None:
            raise RuntimeError(f"Could not find {gpio}")
        self.line.request(consumer=__name__, type=gpiod.LINE_REQ_DIR_OUT)

    def control(self, state):
        if state:
            _LOGGER.info("Turning amp on")
        else:
            _LOGGER.info("Turning amp off")
        self.line.set_value(int(state))

def main():
    # snapclient will invoke us like:
    # child c(exe = settings_.mixer.parameter, args = {"--volume", cpt::to_string(volume), "--mute", mute ? "true" : "false"});

    parser = argparse.ArgumentParser(description="ohsnapmixer")
    parser.add_argument("--volume", action="store", help="volume")
    parser.add_argument("--mute", action="store" default="false", help="mute")

    args = parser.parse_args()
    amp = Amplifier("TRIG_OUT_0")
    amp.control(args.mute != 'true')


if __name__ == '__main__':
    main()

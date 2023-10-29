#!/usr/bin/env python3

import argparse
import asyncio
import gpiod
import logging
import snapcast.control

logging.basicConfig(level="INFO")
_LOGGER = logging.getLogger(__name__)


class Amplifier:
    def __init__(self, gpio):
        self.line = gpiod.find_line(gpio)
        if self.line is None:
            raise RuntimeError(f"Could not find {gpio}")
        self.line.request(consumer=__name__, type=gpiod.LINE_REQ_DIR_OUT)
        self.state = None

    def control(self, state):
        if state == self.state:
            return

        if state:
            _LOGGER.info("Turning amp on")
        else:
            _LOGGER.info("Turning amp off")

        self.line.set_value(int(state))
        self.state = state


def run(server, hostID, amp):
    loop = asyncio.get_event_loop()
    server = loop.run_until_complete(snapcast.control.create_server(loop, server))

    client = server.client(hostID)
    amp.control(not client.muted)

    def volcb(client):
        amp.control(not client.muted)

    client.set_callback(volcb)
    loop.run_forever()


def main():
    parser = argparse.ArgumentParser(description="ohsnapctrl")
    parser.add_argument("--server", required=True, action="store", help="snapcast server to connect to")
    parser.add_argument("--hostID", required=True, action="store", help="host ID to monitor")
    parser.add_argument("--gpio", required=True, action="store", help="GPIO to control")

    args = parser.parse_args()
    amp = Amplifier(args.gpio)
    run(server=args.server, hostID=args.hostID, amp=amp)


if __name__ == '__main__':
    main()

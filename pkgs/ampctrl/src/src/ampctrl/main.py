#!/usr/bin/env python3

import argparse
import asyncio
import enum
import gpiod
import logging
import sys

from mpd.asyncio import MPDClient

logging.basicConfig(level="INFO")
_LOGGER = logging.getLogger(__name__)

def output_enabled(outputs, name):
    for output in outputs:
        if output['outputname'] == name:
            return bool(int(output['outputenabled']))
    raise RuntimeError(f"output {name} was not found in MPD's response")

async def delay_off(amp, delay=10):
    await asyncio.sleep(delay)
    amp.control(False)

class Amplifier:
    def __init__(self, gpio):
        self.line = gpiod.find_line(gpio)
        if self.line is None:
            raise RuntimeError(f"Could not find {gpio}")
        self.line.request(consumer=__name__, type=gpiod.LINE_REQ_DIR_OUT)
        self.state = None
        self.control(False)

    def get_state(self):
        return self.state

    def control(self, state):
        if state != self.state:
            if state:
                _LOGGER.info("Turning amp on")
            else:
                _LOGGER.info("Turning amp off")
            self.line.set_value(int(state))
            self.state = state


async def controller(host, port, output, off_delay, amp):
    class States(enum.Enum):
        OFF = 1
        ON = 2
        DELAY_OFF = 3

    client = MPDClient()

    while True:
        try:
            await client.connect(host, port)

            state = States.OFF
            next_state = None

            task = None
            async for subsystem in client.idle(["output", "player"]):
                status = await client.status()
                outputs = await client.outputs()

                playing = status['state'] == 'play'
                oe = output_enabled(outputs, output)

                _LOGGER.info(f"state: {state}, playing: {playing}, oe: {oe}")

                next_state = state
                if state == States.OFF:
                    if playing and oe:
                        amp.control(True)
                        next_state = States.ON
                elif state == States.ON:
                    if not oe:
                        amp.control(False)
                        next_state = States.OFF
                    elif not playing:
                        task = asyncio.create_task(delay_off(amp, off_delay))
                        next_state = States.DELAY_OFF
                elif state == States.DELAY_OFF:
                    if playing and oe:
                        amp.control(True)
                        next_state = States.ON
                    elif not oe:
                        amp.control(False)
                        next_state = States.OFF

                    if next_state != States.DELAY_OFF:
                        _LOGGER.debug("Cancelling delay_off task")
                        task.cancel()
                        task = None

                state = next_state
        except Exception as e:
            _LOGGER.error("Got exception, retrying in one second...")
            _LOGGER.error(e)
            amp.control(False)
            if task is not None:
                task.cancel()
            await asyncio.sleep(1)

def main():
    parser = argparse.ArgumentParser(description="amp control")
    parser.add_argument("--mpd-host", action="store", default="localhost", help="MPD hostname")
    parser.add_argument("--mpd-port", action="store", default="6600", help="MPD port")
    parser.add_argument("--output-name", action="store", default="CamillaDSP", help="Output to monitor")
    parser.add_argument("--gpio-name", action="store", default="TRIG_OUT_0", help="Name of GPIO that controls the amp")
    parser.add_argument("--off-delay", action="store", default="1800", help="Delay before turning off amp")
    
    args = parser.parse_args()
    amp = Amplifier(args.gpio_name)
    try:
        asyncio.run(controller(args.mpd_host, int(args.mpd_port), args.output_name, int(args.off_delay), amp))
    except KeyboardInterrupt as e:
        amp.control(False)
    finally:
        amp.control(False)

if __name__ == '__main__':
    main()

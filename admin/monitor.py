# -*- coding: utf-8 -*-
import argparse
from ..core import monitor as m

class Main:
    def __init__(self,args: argparse.Namespace = None):
        m.start_monitor()

if __name__ == "__main__":
    # This module should be imported by the main script, so this block is not needed.
    # But it's good practice to keep it for testing purposes.
    from . import options

    parser = argparse.ArgumentParser(description=options.monitor.__doc__)
    options.monitor(parser)
    Main(parser.parse_args())


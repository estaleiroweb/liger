# -*- coding: utf-8 -*-
import argparse
from ..core import monitor as m

class Main:
    def __init__(self,args: argparse.Namespace = None):
        m.start_monitor()

if __name__ == "__main__":
    print('This lib must be called by root of your project started by this framework by another script')
    quit()

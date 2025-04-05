import argparse
from abc import ABC, abstractmethod
from typing import final
from ..core import log


class Main(ABC):
    @final
    def __init__(self, args: argparse.Namespace | dict = None):
        """
        Initializes arguments.

        Args:
            args(argparse.Namespace | dict): Parsed command-line arguments from argparse or dict.
        """
        if isinstance(args, argparse.Namespace):
            args = dict(args._get_kwargs())
        self.args: dict[str, str | None] = args

        if self.args['path']:
            import sys
            from pathlib import Path
            sys.path[0] = f"{Path(self.args['path']).resolve()}"

        log.Logger.level_verbose = log.LOG_ALL
        self.start()

    @abstractmethod
    def start(self):
        pass

import os
import datetime
from . import fn

LOG_NONE: int = 0
"""Log nothing"""

LOG_PRIMARY: int = 1
"""Linked debug_primary method. Debug without LineFeed. Mainly used to shows output of terminal"""

LOG_INFO: int = 2
"""Linked debug_info method. Debug with LineFeed the informations steps of the job"""

LOG_DEBUG: int = 4
"""Linked debug_cmd method. Debug with LineFeed the send commands"""

LOG_WARNING: int = 8
"""Linked debug_warning method. Debug with LineFeed thwhen warning happens"""

LOG_ERROR: int = 16
"""Linked error method. Debug with LineFeed the fatal error"""

LOG_ALL: int = \
    LOG_PRIMARY + \
    LOG_INFO + \
    LOG_DEBUG + \
    LOG_WARNING + \
    LOG_ERROR
"""Debug everything. This is the union of before debugs"""

LOG_DICT: dict = {
    LOG_NONE: "None",
    LOG_PRIMARY: "Primary",
    LOG_INFO: "Info",
    LOG_DEBUG: "Debug",
    LOG_WARNING: "Warning",
    LOG_ERROR: "Error",
    LOG_ALL: "All"
}


class Logger:
    __file = None
    __level = {
        'verbose': LOG_NONE,
        'file': LOG_NONE
    }

    def __init__(self, name: str):
        self.__getConfig()
        self.__name: str = name

    def primary(self, message):
        """
        Output log information based on verbosity settings.

        Args:
            message (str): The text to output
        """
        # self.__log("PRIMARY", message)
        if self.__verbose & LOG_PRIMARY:
            print(f'{message}', end='')

    def info(self, message):
        """
        Output log information based on verbosity settings.

        Args:
            message (str): The text to output
        """
        self.__log(LOG_INFO, message)

    def debug(self, message):
        """
        Output debug information based on verbosity settings.

        Args:
            message (str): The text to output
        """
        self.__log(LOG_DEBUG, message)

    def warning(self, message):
        """
        Output log information based on verbosity settings.

        Args:
            message (str): The text to output
        """
        self.__log(LOG_WARNING, message)

    def error(self, message):
        """
        Output error messages and return False.

        Args:
            message (str): The error message to output

        Returns:
            bool: Always returns False
        """
        self.__log(LOG_ERROR, message)

    @classmethod
    def __getConfig(cls):
        """
        Get the log file path from the configuration file.

        If the path is not set, it will be retrieved from the configuration file.
        """
        if cls.__file != None:
            return
        cls.__file = ''
        cfg = fn.conf('settings.json')
        cfg = cfg.get('log', {})
        if not cfg:
            return

        level = cfg.get('level', {})
        if level:
            cls.__level['verbose'] = level.get('verbose', LOG_NONE)
            cls.__level['file'] = level.get('file', LOG_NONE)

        path, file = cfg.get('path'), cfg.get('file')
        if not path or not file:
            return
        createPath = cfg.get('createPath', False)
        if not os.path.exists(path):
            if not createPath:
                return
            os.makedirs(path, exist_ok=True)

        cls.__file = os.path.join(path, file)

    def __log(self, level: int, message):
        """Internal method to format and print log messages."""
        if level not in LOG_DICT:
            return
        scr = self.__level['verbose'] & level
        fld = self.__level['file'] & level
        if not scr and not fld:
            return

        now = datetime.datetime.now()
        timestamp = now.strftime("%Y-%m-%d %H:%M:%S.%f")
        # timestamp = timestamp[:-3]

        content = f"[{timestamp}] " +\
            f"[{LOG_DICT.get(level)}] " +\
            f"{self.__name}: " +\
            f"{message}"

        if scr:
            print(content)
        if fld:
            self.__logFile(content)

    def __logFile(self, content):
        """
        Append content to the log file.

        Args:
            content (str): The content to append to the log file
        """
        if not self.__file:
            return
        with open(self.__file, 'a') as f:
            f.write(f"{content}\n")

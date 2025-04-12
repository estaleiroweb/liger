import os
import datetime
from . import fn
import inspect

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
    """
    Logger class for managing logging functionality with configurable verbosity levels.

    Attributes:
        level_verbose (int): Verbosity level for console output. Defaults to LOG_NONE.
        level_file (int): Verbosity level for file output. Defaults to LOG_NONE.

    Methods:
        primary(message: str):
            Outputs primary log information based on verbosity settings.

        info(message: str):
            Outputs informational log messages based on verbosity settings.

        debug(message: str):
            Outputs debug log messages based on verbosity settings.

        warning(message: str):
            Outputs warning log messages based on verbosity settings.

        error(message: str) -> bool:
            Outputs error messages and always returns False.
    """
    __file = None
    """Path to the log file. Defaults to None."""

    level_verbose: int = LOG_NONE
    """Verbosity level for console output. Defaults to LOG_NONE."""

    level_file: int = LOG_NONE
    """Verbosity level for file output. Defaults to LOG_NONE."""

    def __init__(self):
        """
        Initializes the instance with the given name and loads the configuration.

        Args:
            name (str): The name to associate with the instance.
        """
        self.__get_config()
        ret: dict = fn.callback_trace(1)  # type: ignore
        # self.__name: str = name
        self.__name: str = ret['short']

        self.__log(LOG_INFO, f'Init Logger {ret['long']} {ret['line']}', True)
        # self.info(f'Init Logger {ret['short']}')

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
    def __get_config(cls):
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
            cls.level_verbose = level.get('verbose', LOG_NONE)
            cls.level_file = level.get('file', LOG_NONE)

        path, file = cfg.get('path'), cfg.get('file')
        if not path or not file:
            return
        createPath = cfg.get('createPath', False)
        if not os.path.exists(path):
            if not createPath:
                return
            os.makedirs(path, exist_ok=True)

        cls.__file = os.path.join(path, file)

    def __log(self, level: int, message, hide_line: bool = False):
        """
        Logs a message with a specified logging level.

        This method checks if the provided logging level is valid and whether
        the message should be logged to the console, a file, or both, based on
        the configured verbosity levels.

        Args:
            level (int): The logging level of the message. Must be a key in LOG_DICT.
            message (str): The message to be logged.
            hide_line (bool): Hide the number line if True

        Returns:
            None: This method does not return a value.

        Behavior:
            - If the logging level is not in LOG_DICT, the method exits without logging.
            - If the logging level does not match the configured verbosity for
              either console or file logging, the method exits without logging.
            - Logs the message to the console if the `level_verbose` bitmask matches the level.
            - Logs the message to a file if the `level_file` bitmask matches the level.
        """
        if level not in LOG_DICT:
            return
        scr = self.level_verbose & level
        fld = self.level_file & level
        if not scr and not fld:
            return

        ln = ''
        if not hide_line:
            try:
                for i in range(2, 1, -1):
                    frame = inspect.stack()[i]
                    # 0 = esta função, 1 = quem chamou
                    break
            except Exception:
                ...
            ln = f' [{frame.lineno}]'
            # print(f"Função: {frame.function}")
            # print(f"Arquivo: {frame.filename}")
            # print(f"Linha: {frame.lineno}")

        now = datetime.datetime.now()
        timestamp = now.strftime("%Y-%m-%dT%H:%M:%S.%f")
        # timestamp = timestamp[:-3]

        content = f"[{timestamp}] " +\
            f"{LOG_DICT.get(level)}-" +\
            f"{self.__name}: " +\
            f"{message}" +\
            ln

        if scr:
            print(content)
        if fld:
            self.__log_file(content)

    def __log_file(self, content):
        """
        Append content to the log file.

        Args:
            content (str): The content to append to the log file
        """
        if not self.__file:
            return
        with open(self.__file, 'a') as f:
            f.write(f"{content}\n")

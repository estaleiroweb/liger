import os
import sys
import time
import signal
import re
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from typing import Callable
from . import fn, log


Logger: log.Logger = log.Logger()
"""A logging object for warning messages."""


def signal_handler(sig, frame):
    """Handles the SIGINT signal (Ctrl+C)."""
    print('\nCtrl+C pressed. Exiting gracefully...')
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)


class Pattern:
    """
    The `Pattern` class provides a mechanism to define and manage regular expression patterns 
    with optional callback functions. It allows matching strings against a list of predefined 
    patterns and retrieving patterns by their index.

    Methods:
        __init__(regex: str | bytes, callback_function: Callable | None = None):
            Initializes a new instance of the `Pattern` class with a compiled regular expression 

        match(item: str) -> int:
            Matches the given string against the list of predefined patterns and returns the 
            index of the first match. Returns -1 if no match is found.

        get(idx: int):
            Retrieves a pattern from the class-level patterns list by its index. Raises an 
            IndexError if the index is out of range.
    """
    __patterns: dict = {}
    """A class-level list that stores all instances of the `Pattern` class."""

    def __init__(self, regex: str | bytes, callback_function: Callable = lambda path_list, cls: None):
        """
        Initializes a new instance of the class with a compiled regular expression
        and an optional callback function.

        Args:
            regex (str | bytes): The regular expression pattern to compile.
            callback_function (Callable, optional): A function to be called 
                when certain conditions are met. Defaults to lambda path, cls: None.

        Attributes:
            regex (Pattern): The compiled regular expression object.
            fn (Callable | None): The callback function provided during initialization.
        """
        self.regex = re.compile(regex)
        self.fn = callback_function
        Pattern.__patterns[regex] = self
        Logger.info(f'Add pattern monitor {regex}')

    @classmethod
    def match(cls, item: str) -> list[int]:
        """
        Matches the given item against a list of predefined patterns and returns the index of the first match.

        Args:
            item (str): The string to be matched against the patterns.

        Returns:
            int: The index of the first matching pattern if a match is found, otherwise None.
        """
        out = []
        if cls.__patterns:
            for i in cls.__patterns:
                pattern = cls.__patterns[i]
                if isinstance(pattern, Pattern):
                    regex: re.Pattern = pattern.regex
                    if regex and regex.search(item):
                        out.append(i)
        return out

    @classmethod
    def get(cls, idx: str | bytes) -> Callable:
        """
        Retrieve a pattern from the class-level patterns list by its index.

        Args:
            idx (str|bytes): The index of the pattern to retrieve.

        Returns:
            Pattern: The pattern at the specified index in the class-level patterns list.
        """
        obj = cls.__patterns.get(idx)
        return obj.fn if isinstance(obj, Pattern) else lambda path_list, cls: None


class Handler(FileSystemEventHandler):
    r"""
        Handler class for monitoring and handling file system events.

        This class extends the `FileSystemEventHandler` to provide custom behavior for
        handling file system events such as file creation, modification, deletion, and
        movement. It maintains an internal state to track events, logs relevant
        information, and triggers a server reboot if necessary.

        Attributes:
            max_time (int): The maximum allowable time (in seconds) since the last
                modification to trigger a reboot. Default is 2 seconds.
            secretOld: The secret value loaded from the `settings.json` configuration file.

        Methods:
            dispatch(event):
                Handles the dispatching of file system events. Logs event details and
                updates internal state based on the event's source and destination paths.

            __add_item(path):

            check_reboot() -> bool:
                Checks if a server reboot is necessary and performs the reboot process if
                required.

        Notes:
            - The class assumes the existence of external dependencies such as `Pattern`
            and `fn` for matching paths and rebooting the application, respectively.
            - The `dispatch` method does not currently handle directory-specific events
            or invoke parent class methods for further processing.
        Examples:
            ```python
            from ...core import monitor
            def callback_function(path,cls):
                ...
            monitor.Pattern(r'.*\.conf$') # add *.conf to reboot server
            monitor.Pattern(r'.*\.py$',callback_function) # add *.py, run callback_function and reboot server
            monitor.Handler.start() # start monitor of files until CTRL+C pressed
            ```
    """
    __cont: int = 0
    """An internal counter to track the number of events handled."""

    __doReboot: bool = False
    """A flag indicating whether a reboot is required."""

    __last_modified: int = 0
    """A timestamp of the last modification."""

    __history: dict[str, str | bytes] = {}
    """A dictionary mapping paths to indices."""

    secretOld = fn.conf('settings.json', nocache=True).get('secret')
    """The secret value loaded from the `settings.json` configuration file that will repass to callback function"""

    max_time: int = 2
    """The maximum allowable time since the last modification to trigger a reboot."""

    er_ignore: re.Pattern = re.compile(r'([\\/])\.git(\1|ignore)')
    # er_ignore:re.Pattern = re.compile(r'([\\/])\.git')
    # er_ignore:re.Pattern = re.compile(r'(\[\\/])(.git\1|.gitignore)')

    __observer = Observer()

    def dispatch(self, event):
        """
            Handles the dispatching of file system events.

            This method processes an incoming event, logs relevant information, 
            and updates internal state based on the event's source and destination paths.

            Args:
                event: An object representing the file system event. It is expected 
                    to have the following attributes:
                    - src_path: The source path of the event.
                    - dest_path (optional): The destination path of the event, if applicable.
                    - is_directory (optional): A boolean indicating if the event pertains 
                        to a directory.

            Side Effects:
                - Increments an internal counter to track the number of events handled.
                - Logs event details, including source and destination paths.
                - Updates internal structures with the source and destination paths.

            Note:
                The method currently does not handle directory-specific events or invoke 
                parent class methods for further processing.
        """
        Handler.__last_modified = time.time()
        if Handler.er_ignore.search(str(event.src_path)):
            return
        Handler.__cont += 1

        logInfo = f'Event_#{Handler.__cont} '
        logInfo += f'src:"{event.src_path}"'
        lst = [event.src_path]
        if event.dest_path and event.dest_path != event.src_path:
            logInfo += f' dst:"{event.dest_path}"'
            lst.append(event.dest_path)

        Logger.info(logInfo)
        for i in lst:
            self.__add_item(i)

        # if event.is_directory:
        #     Logger.info(f"Is directory")
        #     return

        # call on_{created,modified,deleted,moved}
        # super().dispatch(event)
    # def on_created(self, event):
        # Logger.info(f"Create({Handler.__cont}): {event.src_path}")
        # pass
    # def on_modified(self, event):
        # Logger.info(f"Modify({Handler.__cont}): {event.src_path}")
        # pass
    # def on_deleted(self, event):
        # Logger.info(f"Remove({Handler.__cont}): {event.src_path}")
        # pass
    # def on_moved(self, event):
        # Logger.info(f"Move({Handler.__cont}): {event.src_path} -> {event.dest_path}")
        # pass

    @classmethod
    def __add_item(cls, path):
        """
            Adds a file path to the rebuild history and triggers a reboot if necessary.

            Args:
                path (str): The file path to be added.

            Behavior:
                - Updates the last modified timestamp.
                - Checks if a reboot is already scheduled or if the path is invalid or already in history.
                - Matches the path against a pattern to determine its index.
                - Logs the addition of the path and marks the system for reboot if conditions are met.
        """
        if cls.__doReboot == None or not path or path in cls.__history:
            return

        idx_list = Pattern.match(path)
        if not idx_list:
            return

        Logger.info(f'Add_#{Handler.__cont} "{path}" to rebuild')
        cls.__doReboot = True
        cls.__history[path] = idx_list

    @classmethod
    def check_reboot(cls) -> bool:
        """
            Checks if a server reboot is necessary and performs the reboot process if required.

            Returns:
                bool: True if the reboot process was initiated, False otherwise.

            Behavior:
                - If the `__doReboot` flag is not set or the time since the last modification
                is less than `max_time`, the method returns False without performing any action.
                - If a reboot is required:
                    - Sets the `__doReboot` flag to None to prevent further reboots.
                    - Logs a warning indicating the server is being rebuilt.
                    - Iterates through the `__history` dictionary, retrieves the associated
                    function for each path, and executes it if callable.
                    - Logs another warning indicating the server is rebooting.
                    - Calls the `reboot_app` function to perform the actual reboot.

            Exceptions:
                - Catches and prints any exceptions raised during the execution of functions
                associated with paths in `__history`.
        """
        if not cls.__doReboot or time.time() - cls.__last_modified < cls.max_time:
            return False

        # Para não executar mais reboots
        cls.__doReboot = None

        Logger.warning("Rebuilding the server...")
        hst: dict[int, list[str]] = {}
        for path in cls.__history:
            for idx in cls.__history[path]:
                if idx not in hst:
                    hst[idx] = []
                hst[idx].append(path)
        for idx in hst:
            try:
                Pattern.get(idx)(hst[idx], cls)
            except Exception as e:
                print(e)
        Logger.warning("Rebooting the server...")
        fn.reboot_app()
        return True

    @classmethod
    def default_paths(cls):
        import sys
        root = f'{fn.root()}'
        Pattern(fr'^{re.escape(root)}\b')
        return {sys.path[0], root}

    @classmethod
    def start(cls,
              paths: set | list | tuple = None,
              recursive: bool = True):
        """
            Starts monitoring the specified paths for file system changes.
            Args:
                paths (set | list | tuple): A list of directory paths to monitor. Defaults `[sys.path[0],framework_root]`.
                recursive (bool): If True, monitors all subdirectories recursively. Defaults to True.
            Behavior:
                - Logs the start of the monitoring process.
                - Sets up a file system observer and event handler for the specified paths.
                - Continuously monitors the paths for changes until a reboot condition is detected or a KeyboardInterrupt is received.
                - Stops and cleans up the observer when monitoring ends.
            Raises:
                KeyboardInterrupt: If the monitoring is interrupted manually.
        """
        if not paths:
            paths = cls.default_paths()

        Logger.info('Monitoring the project')
        event_handler = cls()
        cls.__observer
        # observer = Observer()
        for path in paths:
            if os.path.exists(path):
                cls.__observer.schedule(
                    event_handler, path, recursive=recursive)
        cls.__observer.start()
        try:
            while True:
                time.sleep(1)
                if cls.check_reboot():
                    break
        except KeyboardInterrupt:
            Logger.info('End monitor')
        cls.__observer.stop()
        cls.__observer.join()
        Logger.info('End script')
        quit()

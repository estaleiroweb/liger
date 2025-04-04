import os
import sys
from . import log
# from typing import Union


class Conf:
    """
    Class to load and access configurations from JSON and INI files.

    Allows loading multiple configuration files, merging them, and accessing values
    using JSONPath. Also supports loading INI files.
    """

    subdir = 'conf'
    """Subfolder that has configurations"""
    path: dict[str, list[str]] = {}
    """Collection of list of directories where configuration files are searched."""

    cache: dict = {}
    """Cache to store already loaded configurations."""

    debug: bool = False
    """Flag to enable debug message display."""

    def __init__(self, file: str, encoding: str = "utf-8", merge: bool = False):
        """
        Initializes a Conf class instance.

        Args:
            file: Configuration file name to load.
            encoding: Configuration file encoding.
        """
        self.__buildPath()
        self.__subdir: str = self.subdir
        self.__dir: list = []
        self.__file: str = file
        self.__encoding: str = encoding
        self.__merge: bool = False
        self.__log = log.Logger(self.__class__.__name__)

    def __str__(self) -> str:
        """Returns the configuration file name."""
        return self.__file

    def __call__(self, jsonPath: str = None) -> dict | list | str | int | float | bool | None:
        """
        Accesses configuration values using JSONPath.

        Args:
            jsonPath: JSONPath expression to access values.

        Returns:
            The found value(s), or the entire configuration dictionary if jsonPath is None.
        """
        conf: dict = self.__cache().get('conf', {})
        if jsonPath is not None and conf:
            import jsonpath_ng
            jsonpath_expr = jsonpath_ng.parse(jsonPath)
            out = [match.value for match in jsonpath_expr.find(conf)]
            return out[0] if len(out) == 1 else out
        return conf

    def __repr__(self) -> str:
        return f'file: {self.__file}, subdir: {self.__subdir}, dir: {self.__dir}, reulst: {self.__call__()}'

    @property
    def dir(self) -> list:
        """Directories where the configuration file was found."""
        return self.__dir

    @property
    def file(self) -> str:
        """Configuration file name."""
        return self.__file

    @property
    def fullfile(self) -> str:
        """Configuration first full file name."""
        if not self.__dir:
            return ''
        return os.path.join(self.__dir[0], self.__file)

    @property
    def encoding(self) -> str:
        """Configuration file encoding."""
        return self.__encoding

    @property
    def key(self):
        """Key of cache"""
        return f'{self.__subdir}/{self.__file}'

    @classmethod
    def __checkDir(cls, dir: str):
        """
        Ensures that a specified directory exists in the class's path configuration.

        This method constructs a full directory path by appending the class's subdirectory
        to the provided directory path. It then resolves the absolute path and checks if 
        the directory exists. If the directory exists and is not already listed in the 
        class's path configuration for the subdirectory, it adds the directory to the list.

        Args:
            dir (str): The base directory path to check and update.
        """
        dir = os.path.join(dir, cls.subdir)
        dir = os.path.realpath(dir)
        if os.path.isdir(dir) and dir not in cls.path[cls.subdir]:
            cls.path[cls.subdir].append(dir)

    @classmethod
    def __buildPath(cls):
        """
        Builds and updates the `path` attribute for the class by traversing directories
        and checking for the existence of a specific subdirectory.

        This method performs the following steps:
        1. Checks if the `subdir` attribute is not already a key in the `path` dictionary.
        2. Initializes an empty list for the `subdir` key in the `path` dictionary.
        3. Iteratively traverses the directory tree upwards starting from the current file's
           directory (`__file__`), calling the `__checkDir` method for each directory.
        4. Additionally, calls the `__checkDir` method for the first entry in `sys.path`.
        5. Reverses the order of the paths collected for the `subdir` key in the `path` dictionary.

        Note:
            - The `__checkDir` method is assumed to handle the logic for checking and
              potentially modifying the `path` attribute for the given directory.
            - This method is intended for internal use and should not be called directly
              from outside the class.

        Raises:
            AttributeError: If the `subdir` or `path` attributes are not defined in the class.
        """
        if cls.subdir not in cls.path:
            cls.path[cls.subdir] = []
            d, dOld = __file__, ''
            while d and d != dOld:
                dOld, d = d, os.path.dirname(d)
                cls.__checkDir(d)
            cls.__checkDir(sys.path[0])
            cls.path[cls.subdir] = cls.path[cls.subdir][::-1]

    def __cache(self) -> dict:
        """
        Caches the configuration data for the current key.

        This method checks if the configuration data for the current key is 
        already present in the cache. If not, it loads the configuration 
        using the `load` method with the merged configuration data and 
        stores it in the cache. Finally, it returns the cached configuration 
        data.

        Returns:
            dict: The cached configuration data for the current key.
        """
        key = self.key
        if key not in Conf.cache:
            Conf.cache[key] = self.load(self.__merge)
        self.__dir = Conf.cache[key]['dir']
        return Conf.cache[key]

    def load(self, merge: bool = False) -> dict:
        """
        Load configuration files from specified directories and return their contents.

        This method iterates through directories specified in `self.path[self.subdir]`,
        attempts to load a configuration file (`self.__file`) from each directory, and
        processes the file based on its extension (.json or .ini). The loaded configuration
        data is either merged with existing data or returned as-is.

        Args:
            merge (bool): If True, merges the loaded configuration with existing data
                          using a recursive merge function. Defaults to False.

        Returns:
            dict: A dictionary containing:
                - 'dir' (list): A list of directories where configuration files were found.
                - 'conf' (dict or None): The loaded configuration data, or None if no
                  valid configuration file was found.

        Raises:
            FileNotFoundError: If the specified configuration file does not exist in any
                               of the directories.
            ValueError: If the configuration file has an unsupported file extension.
        """
        out = {
            'dir': [],
            'conf': None,
        }
        for dir in self.path[self.subdir]:
            fullfile = os.path.join(dir, self.__file)
            if not os.path.isfile(fullfile):
                continue
            self.__log.info(f'Conf Load {fullfile}')
            out['dir'].append(dir)
            conf = None
            if self.__file.endswith('.json'):
                import json
                with open(fullfile, "r", encoding=self.__encoding) as f:
                    conf = json.load(f)
            elif self.__file.endswith('.ini'):
                import configparser
                config = configparser.ConfigParser()
                config.read(fullfile)
                conf = {
                    s: dict(config.items(s)) for s in config.sections()
                }
            else:
                continue
            if merge:
                from .fn import merge_recursive
                out['conf'] = merge_recursive(
                    out['conf'],
                    conf
                )
            else:
                out['conf'] = conf
                break
        self.__dir = out['dir']
        return out

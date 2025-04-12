
__BASE_DIR__ = None
__BASE_ARGS__: list = []
__SENSITIVE_PATTERNS__: list = []


def root():
    """
    Returns the root directory of the framework.

    This function uses the `__file__` attribute to determine the file path of the
    current script and navigates two levels up to return the parent directory.

    Returns:
        pathlib.Path: The root directory of the framework as a Path object.
    """
    from pathlib import Path
    return Path(__file__).resolve().parent.parent


def conf(file: str,
         encoding: str = "utf-8",
         merge: bool = False,
         nocache: bool = False
         ) -> dict:
    """
    Load and return configuration data from a specified file.

    Args:
        file (str): The path to the configuration file.
        encoding (str, optional): The encoding used to read the file. Defaults to "utf-8".
        merge (bool, optional): Whether to merge the configuration with existing data. Defaults to False.
        nocache (bool, optional): If True, forces the configuration to be reloaded instead of using a cached version. Defaults to False.

    Returns:
        dict: The loaded configuration data as a dictionary. If the data is not a dictionary, an empty dictionary is returned.
    """
    from .conf import Conf
    cfg = Conf(file, encoding, merge)
    out = cfg.load() if nocache else cfg()
    return out if isinstance(out, dict) else {}


def get_conf_fullfilename(file: str, path: str = None) -> 'str|bool':
    """
    Resolves the full path to a configuration file within a 'conf' directory.
    Args:
        file (str): The name of the configuration file to locate.
        path (str, optional): The base directory to search for the 'conf' folder. 
                              If not provided, the function will attempt to resolve 
                              the path using the current working directory and the 
                              first entry in `sys.path`.
    Returns:
        str|bool: The full path to the configuration file if found, or `False` if 
                  the file does not exist or the provided path is invalid.
    """
    import os
    if not path:
        import sys
        return get_conf_fullfilename(file, sys.path[0]) or get_conf_fullfilename(file, os.path.realpath('.'))
    elif not os.path.isdir(path):
        return False

    full_file = os.path.join(path, 'conf', file)
    if not os.path.isfile(full_file):
        return False
    return full_file


def dsn(conn: 'str|dict') -> dict:
    """
    Load every configs of database

    Args:
        conn (str|dict): _description_
            - context of `dsn.json`
            - `mariadb://usuario:senha@exemplo.com:8080/caminho/para/recurso?param1=valor1&param2=valor2&a=1&a=2#fragmento`
            - `dict` like the return below
    Returns:
        dict: 
            ```python
            {
                'scheme': str,
                'host': str,
                'port': int,
                'user': str,
                'password': str,
                'database': str,
                'query': dict,
                'params': str,
                'fragment': str,
            }
            ```
    """
    from ..db import dsn as d
    o = d.Dsn()
    c = o(conn)
    return c if isinstance(c, dict) else {}


def copy(source_dir: str = None,
         destination_dir: str = None,
         pattern: str = '*',
         overflow: bool = False):
    """
    Copies files and directories from a source to a destination.

    Args:
        source_dir: Source directory. Defaults to current directory.
        destination_dir: Destination directory. Defaults to current directory.
        pattern: Glob pattern to filter items to be copied. Defaults to '*'.
        overflow: If True, overwrites existing files and directories in the destination.
                 If False, skips items that already exist in the destination.
    """
    import os
    import glob
    import shutil

    if not source_dir:
        source_dir = '.'
    if not destination_dir:
        destination_dir = '.'

    if not os.path.exists(destination_dir):
        os.makedirs(destination_dir)

    items = glob.glob(os.path.join(source_dir, pattern))

    for item in items:
        item_name = os.path.basename(item)
        dest_path = os.path.join(destination_dir, item_name)

        if os.path.isdir(item):
            if os.path.exists(dest_path):
                if overflow:
                    shutil.rmtree(dest_path)
                    shutil.copytree(item, dest_path)
            else:
                shutil.copytree(item, dest_path)
        else:
            if os.path.exists(dest_path):
                if overflow:
                    shutil.copy2(item, dest_path)
            else:
                shutil.copy2(item, dest_path)


def tr_dict(d: dict, tr: dict) -> dict:
    """Translate keys of a dictionary

    Args:
        d (dict): from dict
        tr (dict): translate dict

    Returns:
        dict: dict translated

    Examples:
        ```python
        cfg={
            'passwd':'xpto',
            'username':'admin',
        }
        arr = {
            'type': 'scheme',
            'db': 'database',
            'username': 'user',
            'passwd': 'password',
            'pass': 'password',
        }
        print(tr_dict(cfg, arr))
        # {'password': 'xpto', 'user': 'admin'}
        ```
    """
    out = {}
    for i in tr:
        if i in d and tr[i] not in d:
            d[tr[i]] = d[i]
            del (d[i])
    return d


def simplify_lists(data):
    """
    Transforma um dicionário onde os valores podem ser listas:
    - Se o valor for uma lista com um único elemento, substitui pelo próprio elemento
    - Se o valor for uma lista vazia, substitui por None
    - Outros valores são mantidos como estão
    - Aplica a transformação recursivamente para dicionários aninhados

    Args:
        data: Dicionário a ser transformado

    Returns:
        Dicionário transformado
    """
    if not isinstance(data, dict):
        return data

    result = {}
    for key, value in data.items():
        if isinstance(value, dict):
            result[key] = simplify_lists(value)
        elif isinstance(value, list):
            if len(value) == 1:
                if isinstance(value[0], dict):
                    result[key] = simplify_lists(value[0])
                else:
                    result[key] = value[0]
            elif len(value) == 0:
                result[key] = None
            else:
                result[key] = [simplify_lists(item) if isinstance(item, dict) else item
                               for item in value]
        else:
            result[key] = value

    return result


def merge_recursive(value1, value2):
    """
    Recursively merges two values of the same type.

    This function supports merging dictionaries, sets, lists, tuples, and other types.
    If the types of the two values differ or the first value is None, the second value
    is returned.

    Args:
        value1: The first value to merge. Can be a dictionary, set, list, tuple, or other type.
        value2: The second value to merge. Must be of the same type as value1.

    Returns:
        The merged result:
        - If both values are dictionaries, their keys are merged recursively.
        - If both values are sets, their union is returned.
        - If both values are lists or tuples, their concatenation is returned.
        - For other types, value2 is returned if value1 and value2 differ.

    Examples:
        >>> merge_recursive({'a': 1}, {'b': 2})
        {'a': 1, 'b': 2}

        >>> merge_recursive({1, 2}, {3, 4})
        {1, 2, 3, 4}

        >>> merge_recursive([1, 2], [3, 4])
        [1, 2, 3, 4]

        >>> merge_recursive(None, 42)
        42
    """
    t1, t2 = type(value1), type(value2)
    if t1 != t2 or value1 == None:
        return value2
    if t2 is dict:
        out = {}
        keys = value1.keys() | value2.keys()
        for k in keys:
            if k in value1:
                if k in value2:
                    out[k] = merge_recursive(value1[k], value2[k])
                else:
                    out[k] = value1[k]
            else:
                out[k] = value2[k]
        return out
    elif t2 is set:
        return value1 | value2
    elif t2 in (list, tuple):
        return value1 + value2
    else:
        return value2


def anonymize(content):
    """
    Anonymizes sensitive data recursively.

    Rules:
    - Primitive types (str, int, float, bool) are kept as is
    - Dictionaries have their sensitive keys anonymized based on regex patterns
    - Lists and other iterable structures are processed recursively

    Args:
        content: The content to be anonymized

    Returns:
        Anonymized content maintaining the original structure
    """
    global __SENSITIVE_PATTERNS__
    import re

    defRepl = '********'

    def defaultRepl(match):
        if match[2]:
            return match[1] + '**' + match[3]
        if match[3]:
            return '*****'+match[3]
        return defRepl
    if not __SENSITIVE_PATTERNS__:
        __SENSITIVE_PATTERNS__ = [
            [None, r'^(.{0,3})(.*?)(.{0,3})$', defaultRepl],
            [r'pass(w(or)?d)?|senha|pwd', r'.*'],
            [r'cpf|cnpj|ssn|tax|id', r'^(\d{2}).(\d)*$', '\\1*****\\2'],
            [r'rg|identity|document', r'.*'],
            [r'email|e-mail', r'^(.{0,4})[^@]*@?.*?(.{0,4})$', '\\1**@**\\2'],
            [r'phone|tel(efone)?|tel|cel(ular)?|mobile', r'.*'],
            [r'(credit_?)?card|cart[aã]o_?cr[eé]dito|cc_|card_?number', r'.*'],
            [r'address|endereco|location', r'.*'],
            [r'token|api_?key|secret|jwt', r'.*'],
            [r'passport|passaporte', r'.*'],
            [r'account|conta', r'.*'],
            [r'birth|data_?(nasc|birth)', r'.*'],
            [r'security|seguran[cç]a', r'.*'],
            [r'credentials|credenciais', r'.*'],
            [r'certificate|certificado', r'.*'],
            [r'private|privado', r'.*'],
        ]
        __SENSITIVE_PATTERNS__ = [
            [
                re.compile(v[0]) if v[0] else None,
                re.compile(v[1]),
                v[2] if len(v) > 2 else defRepl
            ]
            for v in __SENSITIVE_PATTERNS__
        ]

        # Regex patterns for sensitive keys

    def is_sensitive(key):
        key_str = str(key)
        for i in range(len(__SENSITIVE_PATTERNS__)):
            if __SENSITIVE_PATTERNS__[i][0]:
                regex = __SENSITIVE_PATTERNS__[i][0]
                if regex.search(key_str):
                    return i

    def process(data, force=False):
        if isinstance(data, (str, int, float, bool, type(None))):
            return data

        elif isinstance(data, dict):
            result = {}
            for key, value in data.items():
                idx = is_sensitive(key)
                if idx or force:
                    if isinstance(value, (int, float, bool)):
                        result[key] = None
                    elif isinstance(value, str):
                        if not idx:
                            idx = 0
                        cfg = __SENSITIVE_PATTERNS__[idx]
                        result[key] = re.sub(cfg[1], cfg[2], value, count=1)
                    elif isinstance(value, dict):
                        result[key] = process(value, True)
                    else:
                        result[key] = defRepl
                else:
                    result[key] = process(value, force)
            return result
        elif isinstance(data, list):
            return [process(item) for item in data]
        elif isinstance(data, tuple):
            return tuple([process(item) for item in data])
        elif isinstance(data, set):
            return {process(item) for item in data}
            out: set = set()
            for item in data:
                out.add(process(item))
            return out
        else:
            return data

    return process(content)


def load_json(file: str, encoding='utf-8'):
    """
    Loads a JSON file and returns its contents as a Python object from root_project/conf.

    Args:
        file (str): The path to the JSON file to be loaded.
        encoding (str, optional): The encoding format to use when reading the file. Defaults to 'utf-8'.

    Returns:
        dict or list: The parsed JSON content, which can be a dictionary or a list depending on the file's structure.

    Raises:
        FileNotFoundError: If the specified file does not exist.
        json.JSONDecodeError: If the file is not a valid JSON format.
    """
    import json
    with open(file, "r", encoding=encoding) as f:
        return json.load(f)
    return {}


def save_json(file: str, data: 'dict|list', indent=4):
    """
    Saves data to a JSON file with the specified indentation to root_project/conf.

    Args:
        file (str): The path to the JSON file where the data will be saved.
        data (dict | list): The data to be serialized and written to the JSON file.
        indent (int, optional): The number of spaces to use for indentation in the JSON file. Defaults to 4.

    Raises:
        TypeError: If `data` is not serializable to JSON.
        IOError: If there is an error writing to the file.

    Example:
        save_json("config.json", {"key": "value"}, indent=2)
    """
    import json
    with open(file, "w") as f:
        json.dump(data, f, indent=indent)


def reboot_app():
    """
    Restart the current Python application.
    This function restarts the currently running Python script by re-executing
    the Python interpreter with the same command-line arguments. It uses the
    `os.execl` method to replace the current process with a new one.
    Note:
        - Any unsaved data or state in the current process will be lost.
        - Ensure that the script is designed to handle restarts gracefully.
    Imports:
        - os: Used for process management.
        - sys: Used to retrieve the current Python executable and arguments.
    Example:
        reboot_app()  # Restarts the current Python script.
    """
    import os
    import sys
    from . import log

    # import pathlib
    # base_dir = pathlib.Path(__file__).resolve().parent.parent
    # os.chdir(str(base_dir))  # Garante que o CWD é o root do pacote
    # base_dir = os.path.realpath(
    #     os.path.join(
    #         os.path.dirname(__file__),
    #         '..'))
    # os.chdir(base_dir)
    # os.chdir(sys.path[0])

    l = log.Logger()

    python = sys.executable
    if __BASE_DIR__:
        l.warning(f'chdir: {__BASE_DIR__}')
        os.chdir(__BASE_DIR__)

    l.warning(f'run: {python} {' '.join(__BASE_ARGS__)}')
    os.execl(python, python, *__BASE_ARGS__)

    # import subprocess
    # subprocess.run(["python3", "script_a_ser_executado.py"])


def rebuild_dsn(secretOld=None, path: str = None):
    """
    Rebuilds the DSN (Data Source Name) configuration file by re-encrypting 
    sensitive data using a new or existing secret key.
    Args:
        secretOld (str, optional): The old secret key used for decryption. 
            If not provided, the current secret key from the configuration 
            will be used.
        path (str, optional): The base path to locate configuration files. 
            Defaults to None.
    Returns:
        None: The function modifies the DSN configuration file in place 
        if changes are made.
    Behavior:
        - Loads the `settings.json` file to retrieve the current secret key.
        - If `secretOld` is not provided, it defaults to the current secret key.
        - Loads the DSN configuration file specified by `Dsn.config_file`.
        - Iterates through the DSN entries:
            - If the entry contains encrypted data (`crypt`), it re-encrypts 
              the data using the new secret key.
            - If the entry contains a plaintext password, it encrypts the 
              password and replaces it with the encrypted value.
        - Saves the updated DSN configuration file if any changes are made.
    """
    from ..db.dsn import Dsn
    from . import crypt
    from . import log
    logger = log.Logger()

    file = get_conf_fullfilename('settings.json', path)
    logger.info(f'Check file "{file}"')
    if not file:
        return

    cfg = load_json(file)
    secret = cfg.get('secret')
    if not secret:
        logger.warning(f'No secrect work')
        return

    if not secretOld:
        secretOld = secret

    file = get_conf_fullfilename(Dsn.config_file, path)
    logger.info(f'Check file "{file}"')
    changed = False
    dsn = load_json(file)
    c = crypt.Crypt(secret)
    cOld = crypt.Crypt(secretOld)
    for i in dsn:
        v = Dsn.check(dsn[i])
        if 'crypt' in v:
            if secret == secretOld:
                continue
            logger.info(f'Change DSN {i}: old crypt')
            v['crypt'] = c(cOld(v['crypt'], True))
            dsn[i] = v
            changed = True
        elif 'password' in v:
            logger.info(f'Change DSN {i}: password to crypt')
            v['crypt'] = c(v['password'])
            del (v['password'])
            dsn[i] = v
            changed = True
    if changed:
        save_json(file, dsn)


def callback_trace(idx=None) -> list[dict] | dict | None:
    """
    Analyzes the current call stack and provides detailed information about each frame.
    Args:
        idx (int, optional): The index of the specific stack frame to retrieve. If None, 
            returns details for all stack frames. Defaults to None.
    Returns:
        list[dict] | dict | None: 
            - If `idx` is None, returns a list of dictionaries, each containing details 
              about a stack frame.
            - If `idx` is provided and valid, returns a dictionary with details about 
              the specified stack frame.
            - If `idx` is out of range, returns None.
    Each dictionary contains the following keys:
        - 'idx': The index of the stack frame.
        - 'file': The file path of the code being executed in the frame.
        - 'line': The line number in the file where the frame is located.
        - 'module': The name of the module containing the frame, if available.
        - 'class': The name of the class (if any) associated with the frame.
        - 'function': The name of the function (if any) associated with the frame.
        - 'short': A short string representation of the frame, including index, module, 
          class, function, and line number.
        - 'long': A detailed string representation of the frame, including index, file 
          path, module, class, function, and line number.
    Notes:
        - The function uses the `inspect` module to analyze the call stack.
        - If the frame corresponds to a method of a class, the class name is included.
        - If the frame corresponds to a module, the module name is included.
        - The `short` and `long` representations are formatted strings for quick reference.
    """
    import inspect
    stack = inspect.stack()[1:]

    def build(idx, frame: inspect.FrameInfo) -> dict:
        file = f'{frame.filename}'
        m, cl, fn, file_sep = '', '', '', ''
        module, cls, func = None, None, None

        if frame.function != '<module>':
            func = frame.function
            fn = f'{func}()'
            file_sep = ':'

            init_locals = frame.frame.f_locals
            if 'self' in init_locals:
                instance = init_locals['self']
                cls = instance.__class__.__name__
                cl = f'{cls}.'

        obj = inspect.getmodule(frame.frame)
        if obj and obj.__name__ != '__main__':
            file_sep = ':'
            module = obj.__name__
            m = module
            if fn or cl:
                m += '@'

        s = f'{m}{cl}{fn}' or f'{file}'
        ln = f' [{frame.lineno}]'
        return {
            'idx': idx,
            'file': frame.filename,
            'line': frame.lineno,
            'module': module,
            'class': cls,
            'function': func,
            'short': f'#{idx}-{s}',
            'long': f'#{idx}-{file}{file_sep}{m}{cl}{fn}',
        }

    if idx == None:
        return [build(idx, frame) for idx, frame in enumerate(stack)]
    if len(stack) > idx+1:
        return build(idx, stack[idx])
    for idx, frame in enumerate(stack):
        d = build(idx, frame)
        print(d['short'])


def monitor_files():
    """
    Initializes and starts the file monitoring process.
    This function sets the logging level to verbose, enabling all log messages,
    and starts the monitoring handler to track file changes or events.
    Imports:
        - `monitor` from the `core` module: Handles file monitoring operations.
        - `log` from the `core` module: Manages logging functionality.
    Side Effects:
        - Sets the logging level to `LOG_ALL` for detailed logging.
        - Starts the monitoring handler.
    Usage:
        Call this function to begin monitoring files with verbose logging enabled.
    """
    from pathlib import Path
    from ..core import monitor
    from ..core import log

    log.Logger.level_verbose = log.LOG_ALL

    monitor.Pattern(r'\.py')
    monitor.Pattern(r'([\\/])conf\1\w+\.(json|ini)')
    monitor.Pattern(
        r'([\\/])conf\1dsn\.json',
        lambda path_list, cls: rebuild_dsn(
            cls.secretOld,
            Path(path_list[0]).resolve().parent.parent
        ))

    monitor.Handler.start()


def monitor_dsn():
    dsn_disct = conf('dsn.json')

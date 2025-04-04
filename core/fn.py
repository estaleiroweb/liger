
__SENSITIVE_PATTERNS: list = []


def conf(file: str,
         encoding: str = "utf-8",
         merge: bool = False
         ) -> dict:
    """Short access to Conf class"""
    from .conf import Conf
    cfg = Conf(file, encoding, merge)
    out = cfg()
    return out if isinstance(out, dict) else {}


def get_conf_fullfilename(file: str, path: str = None) -> 'str|bool':
    import os
    if not path:
        import sys
        return get_conf_fullfilename(file, sys.path[0]) or get_conf_fullfilename(file, os.path.realpath('.'))
    elif not os.path.isdir(path):
        return False

    fullFile = os.path.join(path, 'conf', file)
    if not os.path.isfile(fullFile):
        return False
    return fullFile


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


def trDict(d: dict, tr: dict) -> dict:
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
        print(trDict(cfg, arr))
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
    """Merge two dict recursive"""
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
    global __SENSITIVE_PATTERNS
    import re

    defRepl = '********'

    def defaultRepl(match):
        if match[2]:
            return match[1] + '**' + match[3]
        if match[3]:
            return '*****'+match[3]
        return defRepl
    if not __SENSITIVE_PATTERNS:
        __SENSITIVE_PATTERNS = [
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
        __SENSITIVE_PATTERNS = [
            [
                re.compile(v[0]) if v[0] else None,
                re.compile(v[1]),
                v[2] if len(v) > 2 else defRepl
            ]
            for v in __SENSITIVE_PATTERNS
        ]

        # Regex patterns for sensitive keys

    def is_sensitive(key):
        key_str = str(key)
        for i in range(len(__SENSITIVE_PATTERNS)):
            if __SENSITIVE_PATTERNS[i][0]:
                regex = __SENSITIVE_PATTERNS[i][0]
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
                        cfg = __SENSITIVE_PATTERNS[idx]
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


def loadJSON(file: str, encoding='utf-8'):
    """Load a json file from root_project/conf"""
    import json
    with open(file, "r", encoding=encoding) as f:
        return json.load(f)
    return {}


def saveJSON(file: str, data: 'dict|list', indent=4):
    """Save a json file to root_project/conf"""
    import json
    with open(file, "w") as f:
        json.dump(data, f, indent=indent)


def rebootApp():
    """Reboot the app"""
    import os
    import sys
    python = sys.executable
    os.execl(python, python, *sys.argv)

    # import subprocess
    # subprocess.run(["python3", "script_a_ser_executado.py"])


def rebuildDsn(secretOld=None, path: str = None):
    """Rebuild the DSN"""
    from ..db.dsn import Dsn
    from . import crypt

    file = get_conf_fullfilename('settings.json', path)
    if not file:
        return

    cfg = loadJSON(file)
    secret = cfg.get('secret')
    if not secret:
        return

    if not secretOld:
        secretOld = secret

    file = get_conf_fullfilename(Dsn.config_file, path)
    changed = False
    dsn = loadJSON(file)
    c = crypt.Crypt(secret)
    cOld = crypt.Crypt(secretOld)
    for i in dsn:
        v = Dsn.check(dsn[i])
        if 'crypt' in v:
            if secret == secretOld:
                continue
            v['crypt'] = c(cOld(v['crypt'], True))
            dsn[i] = v
            changed = True
        elif 'password' in v:
            v['crypt'] = c(v['password'])
            del (v['password'])
            dsn[i] = v
            changed = True
    if changed:
        saveJSON(file, dsn)

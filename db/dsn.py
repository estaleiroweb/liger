from ..core import fn
from ..core.conf import Conf


class Dsn:
    """Manager DSN Connections"""
    config_file = 'dsn.json'

    def __init__(self) -> None:
        cfg = Conf(self.config_file)
        self.__cfg: dict = cfg()
        self.__file: str = cfg.fullfile

    def __call__(self, dsn: 'str|dict', value: dict = None) -> dict:
        """
        Load every configs of database

        Args:
            dsn (str|dict): _description_
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

        if value:
            self.__cfg = self.check(value)
            return {}
        if not isinstance(dsn, str):
            return self.__get_dsn_dict(dsn)
        if '://' in dsn:
            return self.__get_dsn_uri(dsn)
        else:
            return self.__get_dsn_context(dsn)

    def __repr__(self) -> str:
        return f'{self.keys}'

    @property
    def keys(self):
        """All keys of DSN connections"""
        return self.__cfg.keys()

    def list_all(self):
        return {self.__get_dsn_context(i) for i in self.keys}

    def save(self):
        fn.save_json(self.__file, self.__cfg)

    def __get_dsn_uri(self, dsn: str):
        from urllib.parse import urlparse, parse_qs
        u = urlparse(dsn)
        arr = [
            'scheme', 'host', 'port',
            'user', 'password',
            'params', 'fragment',
        ]
        cfg = {}
        for i in arr:
            v = getattr(u, i)
            if v:
                cfg[i] = v
        if u.path and u.path != '/':
            cfg['database'] = u.path.strip('/').replace('/', '.')
        if u.query:
            query = fn.simplify_lists(parse_qs(u.query))
            for i in query:
                if i not in cfg and query[i]:
                    cfg[i] = query[i]
        cfg['dsn'] = self.__make_dsn(cfg)
        return cfg

    def __get_dsn_context(self, dsn: str):
        return self.check(self.__get_conn(dsn))

    def __get_dsn_dict(self, dsn: dict):
        cfg = self.check(dsn)
        if 'dsn' not in cfg:
            cfg['dsn'] = self.__make_dsn(cfg)
        return cfg

    @classmethod
    def check(cls, cfg: dict) -> dict:
        cfg = {k.lower(): v for k, v in cfg.items()}
        cfg = fn.tr_dict(cfg, {
            'type': 'scheme',
            'db': 'database',
            'username': 'user',
            'passwd': 'password',
            'pass': 'password',
        })
        return cfg

    def __make_dsn(self, cfg: dict) -> str:
        c = cfg.copy()
        arr = ['scheme', 'username', 'port', 'hostname', 'path',]
        for i in arr:
            if i not in c:
                c[i] = ''
        strDsn = f'{c["scheme"]}://' if c['scheme'] else ''
        strDsn += f'{c["username"]}@' if c['username'] else ''
        port = f':{c["port"]}' if c['port'] else ''
        strDsn += f'{c["hostname"]}{port}' if c['hostname'] else ''
        strDsn += c['path'] if c['path'] else ''
        return strDsn

    def __get_conn(self, dsn: str, inherit: list = []) -> dict:
        conn = self.__cfg[dsn] if dsn in self.__cfg else {}
        if 'dsn' not in conn:
            conn['dsn'] = dsn
        inherit.append(dsn)
        if 'inherit' in conn and dsn not in inherit:
            return self.__get_conn(conn['inherit'], inherit) | conn
        return conn

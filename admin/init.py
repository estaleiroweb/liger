import os
import json
import argparse
import readchar
from ..core import fn
from ..core import crypt
from ..db.dsn import Dsn

class Main:
    settings_file = 'settings.json'
    DEFAULTS = {
        'path': {'default': os.path.realpath('.'), 'descr': 'Project path', 'onafter': '_onafter_path'},
        'name': {'default': None, 'descr': 'Project name'},
        'secret': {'default': None, 'descr': 'Secret key [auto generate]', 'onafter': '_onafter_secret'},
    }

    def __init__(self, args: argparse.Namespace = None):
        """
        Initializes a new project based on the provided arguments.

        Args:
            args: Parsed command-line arguments from argparse.
        """
        print('Starts a project')
        # print(args)
        
        self.args: argparse.Namespace = args
        self.vals: 'dict[str,str|None]' = {}
        self.old: 'dict[str,str|None]' = {}
        self.__getValues()
        self.__confirm()
        self.__copyFiles()
        self.__editSettings()
        self.__editDSN()
        print('End build')

    def __getValues(self):
        self.vals = dict(self.args._get_kwargs())

        for i in self.DEFAULTS:
            if not self.vals[i]:
                d = f' [{self.DEFAULTS[i]["default"]}]' if not None else ''
                self.vals[i] = '' if self.args.quite else input(
                    f"{self.DEFAULTS[i]["descr"]}{d}: ").strip()
                if self.vals[i] == '':
                    self.vals[i] = self.DEFAULTS[i]["default"]
            if 'onafter' in self.DEFAULTS[i]:
                getattr(self, self.DEFAULTS[i]['onafter'])(i)

    def _onafter_path(self, key: str):
        v = str(self.vals[key])
        self.DEFAULTS['name']['default'] = os.path.basename(v)

        file = self.__getFullFile(self.settings_file, v)
        if not file:
            return
        self.old = fn.loadJSON(file)
        for i in ['name', 'secret']:
            self.old[i] = self.old.get(i, None)
        if self.vals['force']:
            return
        if not self.old:
            return
        self.DEFAULTS['name']['default'] = self.old['name']
        self.DEFAULTS['secret']['default'] = self.old['secret']
        self.DEFAULTS['secret']['descr'] = 'Secret key'

    def _onafter_secret(self, key: str):
        if not self.vals['secret']:
            import secrets
            self.vals['secret'] = secrets.token_hex(32)

    def __getFullFile(self, file: str, path: str = None) -> 'str|bool':
        if not path or path == '':
            path = '.'
        elif not os.path.isdir(path):
            return False

        fullFile = os.path.join(path, 'conf', file)
        if not os.path.isfile(fullFile):
            return False
        return fullFile

    def __showValues(self):
        print()
        for i in self.DEFAULTS:
            print(f'{i}: {self.vals[i]}')

    def __confirm(self):
        self.__showValues()
        print()
        print('Confirm [Y|n]: ')
        confirm = readchar.readchar().strip().lower()
        if confirm not in ['', 'y', 's']:
            print('Aborted')
            quit()

    def __copyFiles(self):
        fn.copy(
            os.path.join(os.path.dirname(__file__), 'initFiles'),
            self.vals['path'],
            overflow=self.vals['force'])

    def __editSettings(self):
        if not self.vals['path']:
            self.vals['path'] = '.'

        file = self.__getFullFile(self.settings_file, self.vals['path'])
        if not os.path.isfile(file):
            print(f'File {file} not found')
            quit()

        settings = fn.loadJSON(file)
        settings['name'] = self.vals['name']
        settings['secret'] = self.vals['secret']
        fn.saveJSON(file, settings)

    def __editDSN(self):
        if not self.old['secret']:
            self.old['secret'] = self.vals['secret']
        file = self.__getFullFile(Dsn.config_file, self.vals['path'])
        changed = False
        dsn = fn.loadJSON(file)
        c = crypt.Crypt(self.vals['secret'])
        cOld = crypt.Crypt(self.old['secret'])
        for i in dsn:
            v = Dsn.check(dsn[i])
            if 'crypt' in v:
                if self.vals['secret'] == self.old['secret']:
                    continue
                v['crypt']=c(cOld(v['crypt'],True))
                dsn[i]=v
                changed = True
            elif 'password' in v:
                v['crypt']=c(v['password'])
                del(v['password'])
                dsn[i]=v
                changed = True
        if changed:
            fn.saveJSON(file, dsn)


if __name__ == "__main__":
    # This module should be imported by the main script, so this block is not needed.
    # But it's good practice to keep it for testing purposes.
    from . import options

    parser = argparse.ArgumentParser(description=options.init.__doc__)
    options.init(parser)
    Main(parser.parse_args())

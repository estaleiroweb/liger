# -*- coding: utf-8 -*-
import os
import readchar
from ..core import fn
from . import main
# from ..core import crypt
# from ..db.dsn import Dsn


class Main(main.Main):
    settings_file = 'settings.json'
    DEFAULTS = {
        'path': {'default': os.path.realpath('.'), 'descr': 'Project path', 'onafter': '_onafter_path'},
        'name': {'default': None, 'descr': 'Project name'},
        'secret': {'default': None, 'descr': 'Secret key [auto generate]', 'onafter': '_onafter_secret'},
    }

    def start(self):
        """
        Initializes a new project based on the provided arguments.
        """
        print('Starts a project')

        # print(self.args)
        self.old: dict[str, str | None] = {}
        self.__get_values()
        self.__confirm()
        self.__copy_files()
        self.__edit_settings()
        self.__edit_dsn()
        print('End build')

    def __get_values(self):
        for i in self.DEFAULTS:
            if not self.args[i]:
                d = f' [{self.DEFAULTS[i]["default"]}]' if not None else ''
                self.args[i] = '' if self.args.get('quite') else input(
                    f"{self.DEFAULTS[i]["descr"]}{d}: ").strip()
                if self.args[i] == '':
                    self.args[i] = self.DEFAULTS[i]["default"]
            if 'onafter' in self.DEFAULTS[i]:
                getattr(self, self.DEFAULTS[i]['onafter'])(i)

    def _onafter_path(self, key: str):
        v = str(self.args[key])
        self.DEFAULTS['name']['default'] = os.path.basename(v)

        file = fn.get_conf_fullfilename(self.settings_file, v)
        if not file:
            return
        self.old = fn.load_json(file)
        for i in ['name', 'secret']:
            self.old[i] = self.old.get(i, None)
        if self.args['force']:
            return
        if not self.old:
            return
        self.DEFAULTS['name']['default'] = self.old['name']
        self.DEFAULTS['secret']['default'] = self.old['secret']
        self.DEFAULTS['secret']['descr'] = 'Secret key'

    def _onafter_secret(self, key: str):
        if not self.args['secret']:
            import secrets
            self.args['secret'] = secrets.token_hex(32)

    def __show_values(self):
        print()
        for i in self.DEFAULTS:
            print(f'{i}: {self.args[i]}')

    def __confirm(self):
        self.__show_values()
        print()
        print('Confirm [Y|n]: ')
        confirm = readchar.readchar().strip().lower()
        if confirm not in ['', 'y', 's']:
            print('Aborted')
            quit()

    def __copy_files(self):
        fn.copy(
            os.path.join(os.path.dirname(__file__), 'initFiles'),
            self.args['path'],
            overflow=self.args['force'])

    def __edit_settings(self):
        if not self.args['path']:
            self.args['path'] = '.'

        file = fn.get_conf_fullfilename(self.settings_file, self.args['path'])
        if not os.path.isfile(file):
            print(f'File {file} not found')
            quit()

        settings = fn.load_json(file)
        settings['name'] = self.args['name']
        settings['secret'] = self.args['secret']
        fn.save_json(file, settings)

    def __edit_dsn(self):
        fn.rebuild_dsn(self.old['secret'], self.args['path'])


if __name__ == "__main__":
    # This module should be imported by the main script, so this block is not needed.
    # But it's good practice to keep it for testing purposes.
    import argparse
    from . import options

    parser = argparse.ArgumentParser(description=options.init.__doc__)
    options.init(parser)
    Main(parser.parse_args())

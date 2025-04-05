# -*- coding: utf-8 -*-
import sys
from pathlib import Path
from ..core import fn
from . import main


class Main(main.Main):
    def start(self):
        if not self.args.get('path'):
            self.args['path']=''
        path=Path(self.args['path'])
        sys.path[0]=f'{path.resolve()}'
        
        fn.monitor_files()

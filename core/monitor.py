import sys
import time
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from ..core import fn, log


class MonitorHandler(FileSystemEventHandler):
    maxTime: int = 2
    __paths: 'list[str]' = []

    def __init__(self):
        super().__init__()
        cfg = fn.conf('settings.json')
        self.__secretOld = cfg.get('secret', None)
        self.doReboot: bool = False
        self.last_modified: int = 0
        self.cont: int = 0
        self.__log = log.Logger(self.__class__.__name__)

    @classmethod
    def addPath(cls, path: 'str|list[str]'):
        """Add a path or list of paths to the monitored paths."""
        if isinstance(path, str):
            cls.__paths.append(path)
        elif isinstance(path, list):
            cls.__paths.extend(path)
        else:
            raise TypeError("Path must be a string or a list of strings.")
        
    def dispatch(self, event):
        """Intercepta o evento antes de repassá-lo para os métodos específicos."""
        self.cont += 1

        e = f'Event({self.cont}): '
        f = event.src_path
        t = f'~{event.dest_path}' if event.dest_path and event.dest_path != event.src_path else ''
        self.__log.info(f"{e}{event.event_type}, {f}{t}")

        if event.is_directory:
            self.__log.info(f"Is directory")
            return

        # Agora repassa para os métodos padrão
        # super().dispatch(event)

        self.rebuild(event.src_path)
        self.rebuild(event.dest_path)
        self.reboot()

    def reboot(self):
        """Reboot the server if necessary"""
        if not self.doReboot:
            return

        # Ignora eventos repetidos em menos de self.maxTime segundo
        now = time.time()
        if now - self.last_modified < self.maxTime:
            return
        self.last_modified = now

        self.__log.warning("Rebooting the server...")
        fn.rebootApp()

    def rebuild(self, file=None):
        """Rebuild the project"""
        if not file:
            return
        # Aqui você pode adicionar a lógica para reconstruir o projeto
        self.__log.warning("Rebuilding the project...")

        # se settings tiver alterado secret, regerar dsn.json baseado no secret antigo
        # se dsn.json tiver mudado, checar se existe password em text plain
        self.doReboot = True

    def on_created(self, event):
        # self.__log.info(f"Create({self.cont}): {event.src_path}")
        pass

    def on_modified(self, event):
        # self.__log.info(f"Modify({self.cont}): {event.src_path}")
        pass

    def on_deleted(self, event):
        # self.__log.info(f"Remove({self.cont}): {event.src_path}")
        pass

    def on_moved(self, event):
        # self.__log.info(f"Move({self.cont}): {event.src_path} -> {event.dest_path}")
        pass


def start_monitor():
    """
    Monitor the project directory for changes and reload the server if necessary.
    """
    print('Monitoring the project')

    event_handler = MonitorHandler()
    observer = Observer()
    observer.schedule(
        event_handler,
        sys.path[0],  # os.path.dirname(__file__),
        recursive=True
    )

    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print('End monitor')
        observer.stop()
    observer.join()

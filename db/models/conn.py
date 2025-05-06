from ..main import Main

class Conn:
    """Represents a connection."""
    def __init__(self) -> None:
        self.dsn: str = None
        """Domain server name of the Connection."""
        self.conn: Main = None
        """Domain server name of the Connection."""

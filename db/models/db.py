from . import Conn

class Db:
    """Represents a database."""
    def __init__(self) -> None:
        self.name: str = None
        """Name of the database."""
        
        self.collate: str = None
        """Collate of the database."""
        
        self.comment: str = None
        """Comment of the database."""
        
        self.conn: Conn = None
        """Connection of the database."""

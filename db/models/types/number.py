"""
Number data types.

See:
    - https://dev.mysql.com/doc/refman/8.0/en/numeric-types.html
    - https://mariadb.com/kb/en/data-types-numeric-data-types/
"""
from . import main


class Int(main.Type):
    def __init__(self,
                 length: int = 10,
                 unsigned: bool = False,
                 not_null: bool = False,
                 zero_fill: bool = False,
                 auto_increment: bool = False,
                 default: int = None,
                 on_update: str = None,
                 comment: str = None,
                 expression: str = None,
                 virtual: bool = False,
                 max_length: int = None,
                 min: int = None,
                 max: int = None,
                 ) -> None:
        self.length: int = length
        self.unsigned: bool = unsigned
        self.not_null: bool = not_null
        self.zero_fill: bool = zero_fill
        self.auto_increment: bool = auto_increment
        self.default: str = default
        self.on_update: str = on_update
        self.comment: str = comment
        self.expression: str = expression
        self.virtual: bool = virtual
        self.max_length: int = max_length
        self.min: int = min
        self.max: int = max

class Interger(Int):
    """Synonyms for Int."""
    pass

class TinyInt(Int):
    pass

class SmallInt(Int):
    pass

class MediumInt(Int):
    pass

class BigInt(Int):
    pass

class Int1(TinyInt):
    """Synonyms for TinyInt."""
    pass

class Int2(SmallInt):
    """Synonyms for SmallInt."""
    pass

class Int3(MediumInt):
    """Synonyms for MediumInt."""
    pass

class Int4(Int):
    """Synonyms for Int."""
    pass

class Int8(BigInt):
    """Synonyms for BigInt."""
    pass

class Bit(Int):
    pass

class Bool(Int):
    pass

class Boolean(Bool):
    """Synonyms for Bool."""
    pass

class Decimal(Int):
    def __init__(self,
                 length: int = 10,
                 decimals: int = 0,
                 unsigned: bool = False,
                 not_null: bool = False,
                 zero_fill: bool = False,
                 default: float = None,
                 on_update: str = None,
                 comment: str = None,
                 collate: str = None,
                 expression: str = None,
                 virtual: bool = False,
                 max_length: int = None,
                 min: float = None,
                 max: float = None,
                 ) -> None:
        self.length: int = length
        """precision"""
        self.decimals: int = decimals
        """scale|decimal places"""
        self.unsigned: bool = unsigned
        self.not_null: bool = not_null
        self.zero_fill: bool = zero_fill
        self.default: float = default
        self.on_update: str = on_update
        self.comment: str = comment
        self.collate: str = collate
        self.expression: str = expression
        self.virtual: bool = virtual
        self.max_length: int = max_length
        self.min: float = min
        self.max: float = max

class Dec(Decimal):
    """Synonyms for Decimal."""
    pass

class Numeric(Decimal):
    """Synonyms for Decimal."""
    pass

class Number(Decimal):
    """Synonyms for Decimal."""
    pass

class Fixed(Decimal):
    """Synonyms for Decimal."""
    pass

class Float(Decimal):
    pass

class Double(Float):
    pass

class DoublePrecision(Double):
    """Synonyms for DOUBLE."""
    pass

class Real(Double):
    """Synonyms for DOUBLE."""
    pass

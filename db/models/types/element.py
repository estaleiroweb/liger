from . import string as s
from . import number as n

class Raw(s.LongText):
    pass

class Hidden(s.VarChar):
    pass

class Passwd(s.VarChar):
    pass

class Button(s.VarChar):
    pass

class Phone(s.VarChar):
    pass

class CPF(s.VarChar):
    pass

class CNPJ(s.VarChar):
    pass

class CPF_CNPJ(CPF,CNPJ):
    pass

class CEP(s.VarChar):
    pass

class EMail(s.VarChar):
    pass

class URI(s.VarChar):
    pass

class URL(URI):
    pass

class CIDR(s.INET4):
    pass

class CIDR6(CIDR):
    pass

class MAC_Address(s.VarChar):
    pass

class Mask(n.TinyInt):
    pass

class CN(n.TinyInt):
    pass

class Array(s.VarChar):
    pass

class Combo(s.VarChar):
    pass

class List(Combo):
    pass

class Assoc(s.Enum):
    pass

class Check(n.TinyInt):
    pass

class Radio(s.VarChar):
    pass

class User(s.VarChar):
    pass

class idUser(n.Int):
    pass

class File(s.VarChar):
    pass

class Img(s.VarChar):
    pass

class Search(s.VarChar):
    pass

class GroupCheck(Check):
    pass

class GroupImg(Img):
    pass

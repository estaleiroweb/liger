import base64
from os import urandom
from cryptography.hazmat.primitives.ciphers import (
    Cipher,
    algorithms,
    modes,
    # BlockCipherAlgorithm,
    # CipherAlgorithm,
)
from cryptography.hazmat.decrepit.ciphers import algorithms as dec_algo
from cryptography.hazmat.backends import default_backend
from . import fn


class Crypt:
    """
    Class for encrypting and decrypting strings using various cipher algorithms.
    Windows-compatible implementation using the cryptography library.
    """
    CIPHER_SPECS = {
        'AES': {
            'obj': algorithms.AES,
            'len': {
                'key': [16, 24, 32],  # 128, 192, 256 bits
                'iv': 16,  # 128 bits
            }
        },
        'CAMELLIA': {
            'obj': algorithms.Camellia,
            'len': {
                'key': [16, 24, 32],  # 128, 192, 256 bits
                'iv': 16,  # 128 bits
            }
        },
        'TRIPLEDES': {
            'obj': dec_algo.TripleDES,
            'len': {
                # 128, 192 bits (note: effective security is less)
                'key': [16, 24],
                'iv': 8,  # 64 bits
            }
        },
        'CAST5': {
            'obj': dec_algo.CAST5,
            'len': {
                'key': [16],  # 128 bits
                'iv': 8,  # 64 bits
            }
        },
        'SEED': {
            'obj': dec_algo.SEED,
            'len': {
                'key': [16],  # 128 bits
                'iv': 16,  # 128 bits
            }
        },
        'BLOWFISH': {
            'obj': dec_algo.Blowfish,
            'len': {
                'key': [key_len for key_len in range(4, 57)],  # 32-448 bits
                'iv': 8,  # 64 bits
            }
        },
        # 'ARC4': {  # Note: RC4 is considered insecure
        # 'obj': algorithms.ARC4,
        # 'len': {
        #     'key': [key_len for key_len in range(5, 257)],  # 40-2048 bits
        #     'iv': 0,  # No IV for RC4
        # }
        # },
        'IDEA': {
            'obj': dec_algo.IDEA,
            'len': {
                'key': [16],  # 128 bits
                'iv': 8,  # 64 bits
            }
        },
        'SM4': {
            'obj': algorithms.SM4,
            'len': {
                'key': [16],  # 128 bits
                'iv': 16,  # 128 bits
            }
        },
        'CHACHA20': {
            'obj': algorithms.ChaCha20,
            'len': {
                'key': [32],  # 256 bits
                'iv': 16,  # 128 bits (nonce)
            }
        },
        # 'CHACHA20POLY1305': {
        # 'obj': algorithms.ChaCha20Poly1305,
        # 'len': {
        #     'key': [32],  # 256 bits
        #     'nonce': 12,  # 96 bits
        # }
        # },
        # 'AESCCM': {
        # 'obj': algorithms.AESCCM,
        # 'len': {
        #     'key': [16, 24, 32],  # 128, 192, 256 bits
        #     'nonce': [7, 8, 9, 10, 11, 12, 13],  # 56-104 bits
        # }
        # },
        # 'AESGCM': {
        # 'obj': algorithms.AESGCM,
        # 'len': {
        #     'key': [16, 24, 32],  # 128, 192, 256 bits
        #     'nonce': 12,  # 96 bits (recommended)
        # },
        # },
    }
    CIPHER_MODES = {
        'CBC': {
            'obj': modes.CBC,
            'requires_iv': True,
            'iv_size': 'block_size',  # IV size equals the block size of the algorithm
        },
        'CFB': {
            'obj': modes.CFB,
            'requires_iv': True,
            'iv_size': 'block_size',
        },
        'CFB8': {
            'obj': modes.CFB8,
            'requires_iv': True,
            'iv_size': 'block_size',
        },
        'CTR': {
            'obj': modes.CTR,
            'requires_iv': True,
            'iv_size': 'block_size',  # Called 'nonce' in CTR mode
        },
        'ECB': {
            'obj': modes.ECB,
            'requires_iv': False,
            'iv_size': 0,
        },
        'OFB': {
            'obj': modes.OFB,
            'requires_iv': True,
            'iv_size': 'block_size',
        },
        'GCM': {
            'obj': modes.GCM,
            'requires_iv': True,
            'iv_size': 12,  # 96 bits recommended for GCM
            'additional_data': True,  # Supports authenticated additional data
        },
        'XTS': {
            'obj': modes.XTS,
            'requires_iv': True,
            'iv_size': 16,  # 128 bits
            'key_note': 'Requires double-length key',  # XTS uses two keys
        }
    }

    def __init__(self,
                 key=None,
                 algorithm: str = 'AES',
                 mode: str = 'CBC'):
        """
        Initialize the class with optional key, algorithm, and mode.
        If no key is provided, it will be retrieved from settings.
        Default algorithm is AES and default mode is CBC if not specified.

        Args:
            key (str, optional): Encryption key. Will be adjusted to match required key size.
            algorithm (BlockCipherAlgorithm|CipherAlgorithm, optional): Cipher algorithm to use. Default: AES
            mode (modes.Mode, optional): Cipher mode to use. Default: CBC
        """
        self.__key: str = None
        self.__key_coded: bytes = None
        self.__algorithm: str = None
        self.__mode: str = None

        cfg: dict = fn.conf('settings.json')
        self.econding = cfg.get('charset', 'utf-8')
        self.algorithm = algorithm
        self.mode = mode
        self.key = key or cfg.get('secret')

    def __call__(self, content, decrypt=False):
        """
        Call method allowing the class to be used as a function.

        Args:
            content (str): Content to encrypt or decrypt
            decrypt (bool, optional): Whether to decrypt. Default is False (encrypt).

        Returns:
            str: Encrypted or decrypted content
        """
        return self.decrypt(content) if decrypt else self.encrypt(content)

    @property
    def key_coded(self) -> 'bytes|None':
        """
        Get or set the encryption keyCode.

        Returns:
            str: The key value
        """
        if self.__key_coded:
            return self.__key_coded
        if not self.__key:
            return None
        lens = self.CIPHER_SPECS[self.__algorithm]['len']['key']
        key = self.__key.encode(self.__econding)
        l = len(key)
        if l in lens:
            self.__key_coded = key
            return self.__key_coded
        for i in lens:
            if l < i:
                self.__key_coded = self.__key.ljust(
                    i, '0')[:i].encode(self.__econding)
                return self.__key_coded
        self.__key_coded = self.__key[:lens[-1]].encode(self.__econding)
        return self.__key_coded

    @property
    def econding(self) -> str:
        """
        Get or set the econding.

        Returns:
            str: The econding value
        """
        return self.__econding

    @econding.setter
    def econding(self, val: str):
        self.__econding = val
        self.__key_coded = None

    @property
    def key(self) -> str:
        """
        Get or set the encryption key.

        Returns:
            str: The key value
        """
        return self.__key

    @key.setter
    def key(self, val: str):
        if not val:
            return
        val = val.strip()
        if not val:
            return
        self.__key = val
        self.__key_coded = None

    @property
    def algorithm(self) -> str:
        """
        Get or set the current cipher algorithm.

        Returns:
            str: The current algorithm
        """
        return self.__algorithm

    @algorithm.setter
    def algorithm(self, val: str = 'AES'):
        if not val or val not in self.CIPHER_SPECS:
            if self.__algorithm:
                return
            val = 'AES'
        self.__algorithm = val
        self.__key_coded = None

    @property
    def mode(self) -> str:
        """
        Get or set the current cipher mode.

        Returns:
            modes.Mode: The current mode
        """
        return self.__mode

    @mode.setter
    def mode(self, val: str = 'CBC'):
        if not val or val not in self.CIPHER_MODES:
            if self.__mode:
                return
            val = 'CBC'
        self.__mode = val

    @property
    def lens(self) -> dict:
        """
        Get information about key and IV lengths.

        Returns:
            dict: Dictionary containing current key length, IV length, and allowed key lengths
        """
        l = self.CIPHER_SPECS[self.__algorithm]['len']
        k=self.key_coded
        l['lenKey'] = len(k) if k else 0
        return l

    @property
    def lenIV(self) -> int:
        """
        Get information about IV length.

        Returns:
            int: IV length
        """
        obj = self.CIPHER_SPECS[self.__algorithm]['len']
        return obj['iv'] if 'iv' in obj else 0

    @property
    def cipher(self):
        """
        Get a string representation of the current algorithm and mode.

        Returns:
            str|None: String in format 'Algorithm.Mode' or None if not fully configured
        """
        return f'{self.__algorithm}.{self.__mode}'

    def encrypt(self, plaintext: str) -> 'str|None':
        """
        Encrypt a string using the configured cipher algorithm and mode.

        Args:
            plaintext (str): Text to be encrypted

        Returns:
            str: Base64-encoded encrypted string (IV + ciphertext)
        """
        if not self.key:
            return

        algorithm = self.CIPHER_SPECS[self.__algorithm]['obj'](self.key_coded)
        modeObj = self.CIPHER_MODES[self.__mode]['obj']
        iv = b''
        argIV = []
        if self.CIPHER_MODES[self.__mode]['requires_iv'] and self.lenIV:
            iv = urandom(self.lenIV)
            argIV = [iv]

        encryptor = Cipher(
            algorithm,
            modeObj(*argIV),
            backend=default_backend()
        ).encryptor()

        plaintext_padded = self.__pad(plaintext.encode(self.__econding))
        ciphertext = encryptor.update(plaintext_padded) + encryptor.finalize()
        return base64.b64encode(iv + ciphertext).decode(self.__econding)

    def decrypt(self, encrypted_data: str) -> 'str|None':
        """
        Decrypt an encrypted string.

        Args:
            encrypted_data (str): Base64-encoded encrypted string (IV + ciphertext)

        Returns:
            str: Decrypted text

        Raises:
            ValueError: If decryption fails
        """
        if not self.key:
            return

        encrypted_bytes = base64.b64decode(encrypted_data)
        algorithm = self.CIPHER_SPECS[self.__algorithm]['obj'](self.key_coded)
        modeObj = self.CIPHER_MODES[self.__mode]['obj']
        iv = b''
        argIV = []
        if self.CIPHER_MODES[self.__mode]['requires_iv'] and self.lenIV:
            iv = encrypted_bytes[:self.lenIV]
            encrypted_bytes = encrypted_bytes[self.lenIV:]
            argIV = [iv]

        decryptor = Cipher(
            algorithm,
            modeObj(*argIV),
            backend=default_backend()
        ).decryptor()

        padded_plaintext = decryptor.update(
            encrypted_bytes) + decryptor.finalize()
        plaintext_bytes = self.__unpad(padded_plaintext)
        return plaintext_bytes.decode(self.__econding)

    def __pad(self, data):
        """
        Apply PKCS#7 padding to data.

        Args:
            data (bytes): Data to be padded

        Returns:
            bytes: Padded data
        """
        if not self.lenIV:
            return data
        padding_length = self.lenIV - (len(data) % self.lenIV)
        padding = bytes([padding_length] * padding_length)
        return data + padding

    def __unpad(self, padded_data):
        """
        Remove PKCS#7 padding from data.

        Args:
            padded_data (bytes): Data with padding

        Returns:
            bytes: Data without padding
        """
        padding_length = padded_data[-1]
        return padded_data[:-padding_length]

import pytest
from unittest.mock import patch
from ...core import crypt

pytestmark = pytest.mark.core

config = {'charset': 'utf-8', 'secret': 'default-test-key',
          'algorithm': "AES", 'mode': "CBC"}
config['key']=config['secret']
param_default = {'key': "test-key-12345", 'algorithm': "AES", 'mode': "CBC"}


class TestCrypt:
    def setup_method(self):
        # Mock da função conf para evitar dependência de arquivo settings.json
        self.conf_patcher = patch(str(crypt.__package__) + '.fn.conf')
        self.mock_conf = self.conf_patcher.start()
        # self.mock_conf.return_value = {}
        self.mock_conf.return_value = config

        # Criar instância padrão para testes
        self.c = crypt.Crypt(**param_default)

    def teardown_method(self):
        self.conf_patcher.stop()

    def compare_args(self,c,param):
        assert c.algorithm == param['algorithm']
        assert c.mode == param['mode']
        assert c.key == param['key']
        
    def test_init_default_values(self):
        """Teste de inicialização com valores padrão"""
        c = crypt.Crypt()
        self.compare_args(c,config)

    def test_init_custom_values(self):
        """Teste de inicialização com valores personalizados"""
        param = {'key': "custom-key", 'algorithm': "CAMELLIA", 'mode': "CFB"}
        c = crypt.Crypt(**param)
        self.compare_args(c,param)

    def test_algorithm_setter_validation(self):
        """Teste que o setter de algoritmo valida entradas"""
        v="SM4"
        self.c.algorithm = v
        assert self.c.algorithm == v

        self.c.algorithm = "INVALID_ALGO"
        assert self.c.algorithm == v

        self.c.algorithm = None
        assert self.c.algorithm == v

    def test_mode_setter_validation(self):
        """Teste que o setter de modo valida entradas"""
        v = "CTR"
        self.c.mode = v
        assert self.c.mode == v

        self.c.mode = "INVALID_MODE"
        assert self.c.mode == v

        self.c.mode = None
        assert self.c.mode == v

    def test_key_setter(self):
        """Teste do setter de chave"""
        # Chave normal
        self.c.key = "new-key-value"
        assert self.c.key == "new-key-value"

        # Chave com espaços em branco
        self.c.key = "  key-with-spaces  "
        assert self.c.key == "key-with-spaces"

        # Chave vazia ou somente espaços não deve alterar o valor
        old_key = self.c.key
        self.c.key = ""
        assert self.c.key == old_key

        self.c.key = "   "
        assert self.c.key == old_key

    def test_key_coded_property(self):
        """Teste da propriedade key_coded que ajusta o tamanho da chave"""
        # Para AES, as chaves válidas são 16, 24 ou 32 bytes

        self.c.algorithm=param_default["algorithm"]

        # Teste com chave menor que precisa ser preenchida
        self.c.key = "small"  # 5 bytes
        assert len(self.c.key_coded) == 16  # Deve ser ajustada para 16
        
        # Teste com chave de tamanho exato (16 bytes)
        self.c.key = "exactsixteenbyte"  # 16 bytes
        assert len(self.c.key_coded) == 16
        
        # Teste com chave de tamanho maior 16 (24 bytes)
        self.c.key = "exactsixteenbytes"  # 17 bytes
        assert len(self.c.key_coded) == 24

        # Teste com chave maior que precisa ser truncada
        self.c.key = "a" * 40  # 40 bytes
        assert len(self.c.key_coded) == 32  # Deve ser truncada para 32

    def test_cipher_property(self):
        """Teste da propriedade cipher"""
        self.c.algorithm = "CAMELLIA"
        self.c.mode = "OFB"
        assert self.c.cipher == "CAMELLIA.OFB"

    def test_encion_decion_roundtrip(self):
        """Teste completo de ida e volta (encriptação e decriptação)"""
        original_text = "This is a test message for encion and decion"
        enced = self.c.encrypt(original_text)
        deced = self.c.decrypt(enced)

        assert enced is not None
        assert enced != original_text
        assert deced == original_text

    def test_empty_key_returns_none(self):
        """Teste que encriptação/decriptação retorna None quando não há chave"""
        c = crypt.Crypt(key="")  # Isso não deve alterar a chave padrão

        # Forçando chave vazia para teste
        c._Crypt__key = None

        assert c.encrypt("test") is None
        assert c.decrypt("dGVzdA==") is None

    @pytest.mark.parametrize("algorithm", ["AES", "CAMELLIA", "TRIPLEDES", "CAST5", "SEED", "BLOWFISH", "IDEA", "SM4"])
    def test_different_algorithms(self, algorithm):
        """Teste de diferentes algoritmos de criptografia"""
        if algorithm in crypt.Crypt.CIPHER_SPECS:
            c = crypt.Crypt(key="test-key-for-algos", algorithm=algorithm, mode="CBC")
            original = f"Testing {algorithm} algorithm"

            enced = c.encrypt(original)
            deced = c.decrypt(enced)

            assert deced == original

    @pytest.mark.parametrize("mode", ["CBC", "CFB", "CFB8", "CTR", "ECB", "OFB"])
    def test_different_modes(self, mode):
        """Teste de diferentes modos de criptografia"""
        if mode in crypt.Crypt.CIPHER_MODES:
            c = crypt.Crypt(key="test-key-for-modes", algorithm="AES", mode=mode)
            original = f"Testing {mode} mode"

            enced = c.encrypt(original)
            deced = c.decrypt(enced)

            assert deced == original

    def test_call_method(self):
        """Teste do método __call__"""
        original = "Test message for __call__"

        # Teste de encriptação via __call__
        enced = self.c(original)
        assert enced is not None
        assert enced != original

        # Teste de decriptação via __call__
        deced = self.c(enced, decrypt=True)
        assert deced == original

    def test_padding_methods(self):
        """Teste dos métodos internos de padding"""
        # Teste de _pad e _unpad
        data = b"test" * 5  # 20 bytes

        # Para IV de 16 bytes (AES), padding deve adicionar 12 bytes (16 - (20 % 16))
        padded = self.c._Crypt__pad(data)
        assert len(padded) == 32  # 20 + 12 = 32

        # Teste de unpad
        unpadded = self.c._Crypt__unpad(padded)
        assert unpadded == data

    def test_lens_property(self):
        """Teste da propriedade lens"""
        lens = self.c.lens
        assert 'key' in lens
        assert 'iv' in lens
        assert 'lenKey' in lens

    def test_lenIV_property(self):
        """Teste da propriedade lenIV"""
        # AES usa IV de 16 bytes
        assert self.c.lenIV == 16

        # Mudar para um algoritmo com IV diferente
        self.c.algorithm = "TRIPLEDES"
        assert self.c.lenIV == 8

    def test_econding_property(self):
        """Teste da propriedade econding"""
        assert self.c.econding == "utf-8"

        self.c.econding = "latin-1"
        assert self.c.econding == "latin-1"

    @pytest.mark.parametrize("text", [
        "Simple text",
        "Text with special chars: áéíóú çãõ",
        "Text with symbols: !@#$%^&*()",
        "",  # Texto vazio
        "A" * 1000  # Texto longo
    ])
    def test_various_input_texts(self, text):
        """Teste com vários tipos de texto de entrada"""
        enced = self.c.encrypt(text)
        deced = self.c.decrypt(enced)
        assert deced == text

    def test_invalid_enced_data(self):
        """Teste para verificar o tratamento de dados inválidos na decriptação"""
        with pytest.raises(Exception):
            # Base64 válido mas não é um texto encriptado válido
            self.c.decrypt("SGVsbG8gV29ybGQ=")

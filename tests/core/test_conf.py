import os
import sys
import json
import pytest
from unittest.mock import patch, MagicMock
from ...core.conf import Conf
from pathlib import Path

pytestmark = pytest.mark.core
# pytestmark = [pytest.mark.core, pytest.mark.slow]


# @pytest.mark.core
class TestConf:
    """
    Test suite for the Conf class responsible for loading and managing configuration files.
    """
    settings_content = {
        "name": "test_app",
        "secret": "test_secret",
        "debug": True,
        "charset": "utf-8",
        "formats": {
            "date": "Y-m-d",
            "time": "H:i:s"
        },
        "log": {
            "path": "logs",
            "level": {
                "verbose": 16,
                "file": 10
            }
        }
    }
    dsn_content = {
        "default": {
            "engine": "sqlite",
            "name": "test.db",
            "host": "localhost"
        },
        "test": {
            "engine": "mysql",
            "name": "test_db",
            "user": "test_user",
            "password": "test_pass",
            "host": "localhost",
            "port": 3306
        }
    }
    ini_content = "[DEFAULT]\n"+ \
        "server = localhost\n"+ \
        "port = 8080\n"+ \
        "\n"+ \
        "[database]\n"+ \
        "host = localhost\n"+ \
        "user = user\n"+ \
        "password = password\n"+ \
        "database = test_db\n"+ \
        "\n"+ \
        "[logging]\n"+ \
        "level = INFO\n"+ \
        "file = app.log\n"
    @pytest.fixture
    def setup_conf_files(self, tmp_path):
        """
        Fixture to create temporary configuration files for testing.
        Creates a directory structure with sample configuration files.
        """
        sys.path[0]=f'{tmp_path}'
        conf_dir = tmp_path / "conf"
        conf_dir.mkdir()

        settings_file = conf_dir / "settings.json"
        settings_file.write_text(json.dumps(self.settings_content), encoding="utf-8")

        dsn_file = conf_dir / "dsn.json"
        dsn_file.write_text(json.dumps(self.dsn_content), encoding="utf-8")

        ini_file = conf_dir / "config.ini"
        ini_file.write_text(self.ini_content, encoding="utf-8")

        return tmp_path

    @pytest.fixture
    def mock_path(self, monkeypatch, setup_conf_files):
        """
        Fixture to mock the path behavior to use our temporary directory.
        """
        # Save original path
        original_path = dict(Conf.path)

        # Mock the __buildPath method to use our test directory
        def mock_build_path(cls):
            cls.path[cls.subdir] = [str(setup_conf_files / cls.subdir)]

        monkeypatch.setattr(Conf, "_Conf__buildPath", classmethod(mock_build_path))
        
        # Initialize the path
        Conf._Conf__buildPath()
        
        yield

        # Restore original path
        Conf.path = original_path

    def test_init(self, mock_path):
        """Test initialization of Conf object."""
        conf = Conf("settings.json")
        assert conf.file == "settings.json"
        assert conf.encoding == "utf-8"
        
    def test_load_json_file(self, mock_path):
        """Test loading a JSON configuration file."""
        conf = Conf("settings.json")
        result = conf.load()
        
        assert result['dir']
        assert result['conf'] is not None
        assert result['conf']['name'] == "test_app"
        assert result['conf']['secret'] == "test_secret"
        assert result['conf']['debug'] is True
        
    def test_load_ini_file(self, mock_path):
        """Test loading an INI configuration file."""
        conf = Conf("config.ini")
        result = conf.load()
        
        assert result['dir']
        assert result['conf'] is not None
        assert 'database' in result['conf']
        assert result['conf']['database']['host'] == "localhost"
        assert result['conf']['database']['database'] == "test_db"
        
    def test_load_nonexistent_file(self, mock_path):
        """Test loading a nonexistent file."""
        conf = Conf("nonexistent.json")
        result = conf.load()
        
        assert not result['dir']
        assert result['conf'] is None
        
    def test_jsonpath_access(self, mock_path):
        """Test accessing configuration values using JSONPath."""
        conf = Conf("settings.json")
        
        # Access top-level property
        assert conf("$.name") == "test_app"
        
        # Access nested property
        assert conf("$.formats.date") == "Y-m-d"
        
        # Access deeper nested property
        assert conf("$.log.level.verbose") == 16
        
        # Access multiple values
        log_levels = conf("$.log.level.*")
        assert isinstance(log_levels, list)
        assert 16 in log_levels
        assert 10 in log_levels
        
    def test_full_config_access(self, mock_path):
        """Test accessing the entire configuration."""
        conf = Conf("settings.json")
        config = conf()
        
        assert isinstance(config, dict)
        assert config['name'] == "test_app"
        assert config['formats']['date'] == "Y-m-d"
        
    def test_cache_mechanism(self, mock_path):
        """Test that configurations are properly cached."""
        # Clear the cache
        Conf.cache = {}
        
        # First access should load the configuration
        conf1 = Conf("settings.json")
        config1 = conf1()
        
        # Create a second instance pointing to the same file
        conf2 = Conf("settings.json")
        
        # Mock the load method to verify it's not called again
        original_load = conf2.load
        conf2.load = MagicMock(return_value=original_load())
        
        # Access the configuration through the second instance
        config2 = conf2()
        
        # The load method should not have been called
        conf2.load.assert_not_called()
        
        # The configurations should be identical
        assert config1 == config2
        
    def test_properties(self, mock_path):
        """Test class properties."""
        conf = Conf("settings.json")
        _ = conf()  # Load the configuration
        
        k="conf/settings.json"
        a=f'{Path(f"/{k}")}'
        
        # Test the properties
        assert conf.file == "settings.json"
        assert len(conf.dir) > 0
        assert conf.fullfile.endswith(a)
        assert conf.encoding == "utf-8"
        assert conf.key == k
        
    def test_string_representation(self, mock_path):
        """Test string representation of the object."""
        conf = Conf("settings.json")
        
        # Test __str__
        assert str(conf) == "settings.json"
        
        # Test __repr__
        repr_value = repr(conf)
        assert "file: settings.json" in repr_value
        assert "subdir: conf" in repr_value
        
    def test_merge_configurations(self, mock_path):
        """Test merging multiple configuration files."""
        # Create a merged configuration
        conf = Conf("settings.json", merge=True)
        config = conf()
        
        # Verify the configuration was loaded
        assert isinstance(config,dict)
        assert config['name'] == "test_app"
        
        # Create a non-merged configuration for comparison
        conf_non_merged = Conf("settings.json", merge=False)
        config_non_merged = conf_non_merged()
        
        # They should be the same in this test case (only one file)
        assert config == config_non_merged
        
    @patch('jsonpath_ng.parse')
    def test_jsonpath_parsing(self, mock_parse, mock_path):
        """Test that JSONPath expressions are correctly parsed."""
        # Setup mock
        mock_match = MagicMock()
        mock_match.value = "test_value"
        mock_expr = MagicMock()
        mock_expr.find.return_value = [mock_match]
        mock_parse.return_value = mock_expr
        
        # Execute
        conf = Conf("settings.json")
        result = conf("$.some.path")
        
        # Verify
        mock_parse.assert_called_once_with("$.some.path")
        mock_expr.find.assert_called_once()
        assert result == "test_value"
        
    def test_custom_encoding(self, mock_path):
        """Test using a custom encoding."""
        conf = Conf("settings.json", encoding="latin-1")
        assert conf.encoding == "latin-1"
        
        # Load should still work with the custom encoding
        result = conf.load()
        assert result['conf'] is not None
        
    def test_buildpath_behavior(self):
        """Test the behavior of the __buildPath class method."""
        # Save original path
        original_path = dict(Conf.path)
        
        # Clear the path
        Conf.path = {}
        
        # Call the method
        Conf._Conf__buildPath()
        
        # Verify that paths were discovered
        assert Conf.subdir in Conf.path
        assert isinstance(Conf.path[Conf.subdir], list)
        assert Conf.subdir == 'conf'
        assert len(Conf.path[Conf.subdir]) > 0
        
        # Restore original path
        Conf.path = original_path
        
    def test_checkdir_behavior(self, tmp_path):
        """Test the behavior of the __checkDir class method."""
        # Save original path
        original_path = dict(Conf.path)
        
        # Set up a test path dictionary
        test_subdir = "test_conf"
        Conf.subdir = test_subdir
        Conf.path = {test_subdir: []}
        
        # Create a test directory
        test_dir = tmp_path / test_subdir
        test_dir.mkdir()
        
        # Call the method
        Conf._Conf__checkDir(str(tmp_path))
        
        # Verify the directory was added
        assert str(test_dir) in Conf.path[test_subdir]
        
        # Restore original values
        Conf.subdir = "conf"
        Conf.path = original_path
    
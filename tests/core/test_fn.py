import pytest
import os
import json
import shutil
from pathlib import Path
from ...core import fn

pytestmark = pytest.mark.core


class Test_root:
    def test_root_path(self):
        """
        Tests the root function to ensure it returns the correct path.

        Verifies that the function correctly resolves the root directory
        of the framework by navigating two levels up from the current file.
        """
        expected = Path(fn.__file__).parent.parent
        assert fn.root() == expected

    def test_root_is_directory(self):
        """
        Tests that the root function returns a valid directory.

        Verifies that the resolved path exists and is a directory.
        """
        root_path = fn.root()
        assert root_path.exists()
        assert root_path.is_dir()


class Test_merge_recursive:
    def test_dicts(self):
        """
        Tests the merge_recursive function with two dictionaries.

        Verifies that the function correctly merges two dictionaries, handling nested
        dictionaries and differing keys.
        """
        dict1 = {"a": 1, "b": {"x": 2, "y": 3}}
        dict2 = {"b": {"y": 4, "z": 5}, "c": 6}
        expected = {"a": 1, "b": {"x": 2, "y": 4, "z": 5}, "c": 6}
        assert fn.merge_recursive(dict1, dict2) == expected

    def test_sets(self):
        """
        Tests the merge_recursive function with two sets.

        Verifies that the function correctly merges two sets, creating a union of the elements.
        """
        set1 = {1, 2, 3}
        set2 = {3, 4, 5}
        expected = {1, 2, 3, 4, 5}
        assert fn.merge_recursive(set1, set2) == expected

    def test_lists(self):
        """
        Tests the merge_recursive function with two lists.

        Verifies that the function correctly merges two lists, concatenating them.
        """
        list1 = [1, 2, 3]
        list2 = [3, 4, 5]
        expected = [1, 2, 3, 3, 4, 5]
        assert fn.merge_recursive(list1, list2) == expected

    def test_tuples(self):
        """
        Tests the merge_recursive function with two tuples.

        Verifies that the function correctly merges two tuples, concatenating them.
        """
        tuple1 = (1, 2, 3)
        tuple2 = (3, 4, 5)
        expected = (1, 2, 3, 3, 4, 5)
        assert fn.merge_recursive(tuple1, tuple2) == expected

    def test_different_types(self):
        """
        Tests the merge_recursive function with different types.

        Verifies that the function correctly handles cases where the input values have
        different types, or when one of the values is None.
        """
        assert fn.merge_recursive(1, "a") == "a"
        assert fn.merge_recursive({"a": 1}, [1, 2]) == [1, 2]
        assert fn.merge_recursive(None, 10) == 10

    def test_nested_dicts(self):
        """
        Tests the merge_recursive function with nested dictionaries.

        Verifies that the function correctly merges nested dictionaries, handling
        overlapping keys and differing levels of nesting.
        """
        dict1 = {"a": {"b": 1, "c": 2}, "d": 3}
        dict2 = {"a": {"c": 4, "e": 5}, "f": 6}
        expected = {"a": {"b": 1, "c": 4, "e": 5}, "d": 3, "f": 6}
        assert fn.merge_recursive(dict1, dict2) == expected


class Test_tr_dict:
    def test_basic(self):
        cfg = {
            'passwd': 'xpto',
            'username': 'admin',
        }
        arr = {
            'username': 'user',
            'passwd': 'password',
        }
        expected = {
            'password': 'xpto',
            'user': 'admin',
        }
        assert fn.tr_dict(cfg, arr) == expected

    def test_with_extra_keys_in_tr(self):
        cfg = {
            'passwd': 'xpto',
            'username': 'admin',
            'other': 'value',
        }
        arr = {
            'username': 'user',
            'passwd': 'password',
            'extra': 'new_key',
        }
        expected = {
            'password': 'xpto',
            'user': 'admin',
            'other': 'value',
        }
        assert fn.tr_dict(cfg, arr) == expected

    def test_with_extra_keys_in_d(self):
        cfg = {
            'passwd': 'xpto',
            'username': 'admin',
            'extra': 'value',
        }
        arr = {
            'username': 'user',
            'passwd': 'password',
        }
        expected = {
            'password': 'xpto',
            'user': 'admin',
            'extra': 'value',
        }
        assert fn.tr_dict(cfg, arr) == expected

    def test_no_translation(self):
        cfg = {
            'key1': 'value1',
            'key2': 'value2',
        }
        arr = {
            'key3': 'new_key3',
            'key4': 'new_key4',
        }
        expected = {
            'key1': 'value1',
            'key2': 'value2',
        }
        assert fn.tr_dict(cfg, arr) == expected

    def test_empty_dicts(self):
        cfg = {}
        arr = {}
        expected = {}
        assert fn.tr_dict(cfg, arr) == expected

    def test_same_key_translation(self):
        cfg = {'old_key': 'value'}
        arr = {'old_key': 'new_key'}
        expected = {'new_key': 'value'}
        assert fn.tr_dict(cfg, arr) == expected

    def test_multiple_translations(self):
        cfg = {'old_key1': 'value1', 'old_key2': 'value2', 'old_key3': 'value3'}
        arr = {'old_key1': 'new_key1', 'old_key2': 'new_key2'}
        expected = {'new_key1': 'value1',
                    'new_key2': 'value2', 'old_key3': 'value3'}
        assert fn.tr_dict(cfg, arr) == expected

    def test_translation_already_exist(self):
        cfg = {'old_key': 'value', 'new_key': 'other_value'}
        arr = {'old_key': 'new_key'}
        expected = {'new_key': 'other_value', 'old_key': 'value'}
        assert fn.tr_dict(cfg, arr) == expected


class Test_simplify_lists:
    def compare(self, data, expected):
        assert fn.simplify_lists(data) == expected

    def test_empty_list(self):
        data = {"a": []}
        expected = {"a": None}
        self.compare(data, expected)

    def test_single_item_list(self):
        data = {"a": [1]}
        expected = {"a": 1}
        self.compare(data, expected)

    def test_multi_item_list(self):
        data = {"a": [1, 2, 3]}
        expected = {"a": [1, 2, 3]}
        self.compare(data, expected)

    def test_nested_dict(self):
        data = {"a": {"b": [1]}}
        expected = {"a": {"b": 1}}
        self.compare(data, expected)

    def test_nested_list_with_dict(self):
        data = {"a": [{"b": [1]}]}
        expected = {"a": {"b": 1}}
        self.compare(data, expected)

    def test_complex_structure(self):
        data = {
            "a": [1, {"b": [2, 3], "c": [4]}, 5],
            "d": [],
            "e": [6],
            "f": "string",
        }
        expected = {
            "a": [1, {"b": [2, 3], "c": 4}, 5],
            "d": None,
            "e": 6,
            "f": "string",
        }
        self.compare(data, expected)

    def test_no_lists(self):
        data = {"a": 1, "b": "string", "c": {"d": 2}}
        expected = {"a": 1, "b": "string", "c": {"d": 2}}
        self.compare(data, expected)

    def test_empty_dict(self):
        data = {}
        expected = {}
        self.compare(data, expected)

    def test_not_a_dict(self):
        data = [1, 2, 3]
        expected = [1, 2, 3]
        self.compare(data, expected)


class Test_anonymize:
    data = {
        "password": "secret",
        "email": "test@example.com",
        "cpf": 12345678900,
        "cpf2": '12345678900',
        "private": True,
        "token": "abc123xyz",
        "address": {"street": "123 Main St", "city": "Anytown"},
    }
    expected = {
        "password": "********",
        "email": "test**@**.com",
        "cpf": None,
        "cpf2": "12*****0",
        "private": None,
        "token": "********",
        "address": {"street": "123** St", "city": "Any**own"},
    }

    def simgle_compare(self, k):
        data = {k: self.data[k]}
        expected = {k: self.expected[k]}
        assert fn.anonymize(data) == expected

    def test_basic_string(self):
        self.simgle_compare("password")
        self.simgle_compare("cpf2")

    def test_basic_int(self):
        self.simgle_compare("cpf")

    def test_basic_bool(self):
        self.simgle_compare("private")

    def test_nested_dict(self):
        e = 'email'
        data = {"user": {e: self.data[e], "name": "John"}}
        expected = {"user": {e: self.expected[e], "name": "John"}}
        assert fn.anonymize(data) == expected

    def test_list(self):
        p = 'password'
        e = 'email'
        data = [{p: self.data[p]}, {e: self.data[e]}]
        expected = [{p: self.expected[p]}, {e: self.expected[e]}]
        assert fn.anonymize(data) == expected

    def test_tuple(self):
        p = 'password'
        e = 'email'
        data = ({p: self.data[p]}, {e: self.data[e]})
        expected = ({p: self.expected[p]}, {e: self.expected[e]})
        assert fn.anonymize(data) == expected

    def test_set(self):
        data = {"password": {"secret"}, "email": {"test@example.com"}}
        expected = {"password": "********", "email": "********"}
        assert fn.anonymize(data) == expected

    def test_mixed_data(self):
        p = 'password'
        e = 'email'
        t = 'token'
        a = 'address'
        data = {
            "user": {
                "name": "John",
                e: self.data[e],
                a: self.data[a],
            },
            "items": [
                {"product": "Laptop", "price": 1000, t: self.data[t]},
                {"product": "Mouse", "price": 20, p: self.data[p]},
            ],
            "non_sensitive": "data",
        }
        expected = {
            "user": {
                "name": "John",
                e: self.expected[e],
                a: self.expected[a],
            },
            "items": [
                {"product": "Laptop", "price": 1000, t: self.expected[t]},
                {"product": "Mouse", "price": 20, p: self.expected[p]},
            ],
            "non_sensitive": "data",
        }
        assert fn.anonymize(data) == expected

    def test_no_sensitive_data(self):
        data = {"name": "John", "city": "Anytown"}
        assert fn.anonymize(data) == data

    def test_empty_dict(self):
        assert fn.anonymize({}) == {}

    def test_none_value(self):
        data = {"key": None}
        expected = {"key": None}
        assert fn.anonymize(data) == expected


class Test_get_conf_fullfilename:
    def setup_method(self):
        self.path = os.path.realpath(
            os.path.join(
                os.path.dirname(fn.__file__),
                '..',
                'admin',
                'initFiles',
            )
        )
        if not os.path.isdir(self.path):
            self.path = '.'

    @pytest.mark.parametrize("file", ["settings.json", "dsn.json", "web.json", "email.json", "contact.json", "menu.json"])
    def test_path(self, file):
        data = fn.get_conf_fullfilename(file, self.path)
        if not data:
            assert '' == file
            data = ''
        assert True


class Test_copy:
    def setup_method(self):
        self.source_dir = "test_source"
        self.destination_dir = "test_destination"
        os.makedirs(self.source_dir, exist_ok=True)
        os.makedirs(self.destination_dir, exist_ok=True)

    def teardown_method(self):
        shutil.rmtree(self.source_dir, ignore_errors=True)
        shutil.rmtree(self.destination_dir, ignore_errors=True)

    def test_copy_all_files(self):
        """
        Tests the copy function to ensure all files are copied from source to destination.
        """
        with open(os.path.join(self.source_dir, "file1.txt"), "w") as f:
            f.write("content1")
        with open(os.path.join(self.source_dir, "file2.txt"), "w") as f:
            f.write("content2")

        fn.copy(self.source_dir, self.destination_dir)

        assert os.path.exists(os.path.join(self.destination_dir, "file1.txt"))
        assert os.path.exists(os.path.join(self.destination_dir, "file2.txt"))

    def test_copy_with_pattern(self):
        """
        Tests the copy function with a specific pattern to ensure only matching files are copied.
        """
        with open(os.path.join(self.source_dir, "file1.txt"), "w") as f:
            f.write("content1")
        with open(os.path.join(self.source_dir, "file2.log"), "w") as f:
            f.write("content2")

        fn.copy(self.source_dir, self.destination_dir, pattern="*.txt")

        assert os.path.exists(os.path.join(self.destination_dir, "file1.txt"))
        assert not os.path.exists(os.path.join(
            self.destination_dir, "file2.log"))

    def test_copy_overwrite(self):
        """
        Tests the copy function with the overflow option to ensure files are overwritten.
        """
        with open(os.path.join(self.source_dir, "file1.txt"), "w") as f:
            f.write("new content")
        with open(os.path.join(self.destination_dir, "file1.txt"), "w") as f:
            f.write("old content")

        fn.copy(self.source_dir, self.destination_dir, overflow=True)

        with open(os.path.join(self.destination_dir, "file1.txt"), "r") as f:
            assert f.read() == "new content"

    def test_copy_no_overwrite(self):
        """
        Tests the copy function without the overflow option to ensure existing files are not overwritten.
        """
        with open(os.path.join(self.source_dir, "file1.txt"), "w") as f:
            f.write("new content")
        with open(os.path.join(self.destination_dir, "file1.txt"), "w") as f:
            f.write("old content")

        fn.copy(self.source_dir, self.destination_dir, overflow=False)

        with open(os.path.join(self.destination_dir, "file1.txt"), "r") as f:
            assert f.read() == "old content"

    def test_copy_directory(self):
        """
        Tests the copy function to ensure directories are copied correctly.
        """
        sub_dir = os.path.join(self.source_dir, "subdir")
        os.makedirs(sub_dir, exist_ok=True)
        with open(os.path.join(sub_dir, "file.txt"), "w") as f:
            f.write("content")

        fn.copy(self.source_dir, self.destination_dir)

        assert os.path.exists(os.path.join(
            self.destination_dir, "subdir", "file.txt"))


class Test_load_json:
    def test_load_valid_json_dict(self, tmp_path):
        """Test loading a valid JSON file with dictionary content."""
        # Create a temporary JSON file
        test_data = {"key": "value", "nested": {"inner": 42}}
        file_path = tmp_path / "test.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(test_data, f)

        # Test loading the file
        result = fn.load_json(file_path)
        assert result == test_data

    def test_load_valid_json_list(self, tmp_path):
        """Test loading a valid JSON file with list content."""
        test_data = [1, 2, {"key": "value"}, [4, 5, 6]]
        file_path = tmp_path / "test_list.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(test_data, f)

        result = fn.load_json(file_path)
        assert result == test_data

    def test_load_with_custom_encoding(self, tmp_path):
        """Test loading a JSON file with custom encoding."""
        test_data = {"key": "value"}
        file_path = tmp_path / "test_encoding.json"
        with open(file_path, "w", encoding="latin-1") as f:
            json.dump(test_data, f)

        result = fn.load_json(file_path, encoding="latin-1")
        assert result == test_data

    def test_file_not_found(self):
        """Test that FileNotFoundError is raised when file doesn't exist."""
        with pytest.raises(FileNotFoundError):
            fn.load_json("nonexistent_file.json")

    def test_invalid_json(self, tmp_path):
        """Test that JSONDecodeError is raised when the file is not valid JSON."""
        file_path = tmp_path / "invalid.json"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write("{invalid json")

        with pytest.raises(json.JSONDecodeError):
            fn.load_json(file_path)


class Test_save_json:
    def test_save_dict_to_json(self, tmp_path):
        """Test saving a dictionary to a JSON file."""
        test_data = {"key": "value", "nested": {"inner": 42}}
        file_path = tmp_path / "output.json"

        fn.save_json(file_path, test_data)

        # Verify file contents
        with open(file_path, "r") as f:
            saved_data = json.load(f)

        assert saved_data == test_data

    def test_save_list_to_json(self, tmp_path):
        """Test saving a list to a JSON file."""
        test_data = [1, 2, {"key": "value"}, [4, 5, 6]]
        file_path = tmp_path / "output_list.json"

        fn.save_json(file_path, test_data)

        # Verify file contents
        with open(file_path, "r") as f:
            saved_data = json.load(f)

        assert saved_data == test_data

    def test_save_with_custom_indent(self, tmp_path):
        """Test saving JSON with custom indentation."""
        test_data = {"key": "value"}
        file_path = tmp_path / "custom_indent.json"

        # Use custom indent of 2
        fn.save_json(file_path, test_data, indent=2)

        # Read the raw file content to check indentation
        with open(file_path, "r") as f:
            content = f.read()

        # Check that the indentation is 2 spaces
        assert '  "key"' in content

    def test_save_to_nonexistent_directory(self, tmp_path):
        """Test saving to a file in a directory that doesn't exist raises an error."""
        test_data = {"key": "value"}
        file_path = tmp_path / "nonexistent_dir" / "file.json"

        with pytest.raises(IOError):
            fn.save_json(file_path, test_data)

    def test_non_serializable_data(self, tmp_path):
        """Test that saving non-serializable data raises a TypeError."""
        # Create a class that can't be serialized to JSON
        class NonSerializable:
            pass

        test_data = {"key": NonSerializable()}
        file_path = tmp_path / "non_serializable.json"

        with pytest.raises(TypeError):
            fn.save_json(file_path, test_data)


class Test_conf:
    """Done by tes_conf"""
    pass


class Test_dsn:
    """Done by tes_dsn"""
    pass

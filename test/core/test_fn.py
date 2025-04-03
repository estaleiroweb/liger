import pytest
from ...core import fn


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


class Test_trDict:
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
        assert fn.trDict(cfg, arr) == expected

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
        assert fn.trDict(cfg, arr) == expected

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
        assert fn.trDict(cfg, arr) == expected

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
        assert fn.trDict(cfg, arr) == expected

    def test_empty_dicts(self):
        cfg = {}
        arr = {}
        expected = {}
        assert fn.trDict(cfg, arr) == expected

    def test_same_key_translation(self):
        cfg = {'old_key': 'value'}
        arr = {'old_key': 'new_key'}
        expected = {'new_key': 'value'}
        assert fn.trDict(cfg, arr) == expected

    def test_multiple_translations(self):
        cfg = {'old_key1': 'value1', 'old_key2': 'value2', 'old_key3': 'value3'}
        arr = {'old_key1': 'new_key1', 'old_key2': 'new_key2'}
        expected = {'new_key1': 'value1',
                    'new_key2': 'value2', 'old_key3': 'value3'}
        assert fn.trDict(cfg, arr) == expected

    def test_translation_already_exist(self):
        cfg = {'old_key': 'value', 'new_key': 'other_value'}
        arr = {'old_key': 'new_key'}
        expected = {'new_key': 'other_value', 'old_key': 'value'}
        assert fn.trDict(cfg, arr) == expected


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


class Test_conf:
    ...


class Test_dsn:
    ...


class Test_copy:
    ...


class Test_loadJSON:
    ...


class Test_saveJSON:
    ...

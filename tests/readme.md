# Test

Use the code:

```bash
cd /venv/Lib/site-packages/ligre/test
pytest -vv
# all test double verbose

pytest -vv core/test_fn.py
# to especific script

pytest -k "test_conf"
# base name

pytest -m danger
# mark

pytest -m 'danger or db or slow'
# multi mark
```

Mark to file

```python
import pytest

pytestmark = pytest.mark.danger
```

Multi Mark to file

```python
import pytest

pytestmark = [pytest.mark.danger, pytest.mark.slow]
```

Mark to class or function

```python
import pytest

@pytest.mark.slow
class TestConf:
    ...

@pytest.mark.slow
def test_conf:
    ...

```

Multi Mark to class or function

```python
import pytest

@pytest.mark.slow
@pytest.mark.danger
class TestConf:
    ...

@pytest.mark.slow
@pytest.mark.danger
def test_conf:
    ...

```

config `pytest.ini`

```ini
[pytest]
minversion = 6.0
addopts = -ra -q
; addopts = -vv
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
; pythonpath = src
markers =
    slow: testes que demoram mais
    db: testes que acessam banco de dados
    core
    web
    admin
    danger
```

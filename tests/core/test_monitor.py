# test_monitor.py
import pytest
from unittest.mock import patch, MagicMock, call
from ...core import monitor
from typing import Callable


class MockEvent:
    def __init__(self, src_path, dest_path=None):
        self.src_path = src_path
        self.dest_path = dest_path
        self.is_directory = False


@pytest.fixture(autouse=True)
def reset_patterns():
    """Reset Pattern and Handler state before each test"""
    TestPattern.reset()
    # Reset Handler state
    monitor.Handler.max_time = 2
    monitor.Handler._Handler__cont = 0
    monitor.Handler._Handler__doReboot = False
    monitor.Handler._Handler__last_modified = 0
    monitor.Handler._Handler__history = {}


class TestPattern:
    @classmethod
    def reset(cls):
        monitor.Pattern._Pattern__patterns = {}

    def test_init(self):
        """Test Pattern initialization"""
        self.reset()
        def callback(path, cls): return f"Processed {path}"
        pattern = monitor.Pattern(r"test_pattern", callback)

        assert pattern.regex.pattern == "test_pattern"
        assert pattern.fn == callback
        assert r"test_pattern" in monitor.Pattern._Pattern__patterns

    def test_match_with_match(self):
        """Test match method with a matching pattern"""
        self.reset()
        data = r"^/test/path"
        monitor.Pattern(data)

        result = monitor.Pattern.match("/test/path/file.txt")

        assert result == [data]

    def test_match_without_match(self):
        """Test match method with no matching pattern"""
        self.reset()
        monitor.Pattern(r"^/other/path")

        result = monitor.Pattern.match("/test/path/file.txt")

        assert result == []

    def test_get_existing_pattern(self):
        """Test get method with an existing pattern"""
        self.reset()
        def callback(path, cls=None): return f"Processed {path}"
        data = "test_pattern"
        p = 'xpto'
        monitor.Pattern(data, callback)

        result = monitor.Pattern.get(data)
        # assert monitor.Pattern._Pattern__patterns == {}
        assert isinstance(result, Callable)
        assert result == callback
        assert result(p) == callback(p)

    def test_get_nonexistent_pattern(self):
        """Test get method with a nonexistent pattern"""
        self.reset()
        result = monitor.Pattern.get("nonexistent_pattern")

        # Should return default lambda
        assert callable(result)
        assert result("test", None) is None

    def test_pattern_registration(self):
        """Test registering patterns with and without callback functions"""
        # Define a test callback function
        def callback_function(path, cls):
            return f"Processed {path}"

        # Register patterns
        monitor.Pattern(r'.*\.conf$')  # Without callback
        monitor.Pattern(r'.*\.py$', callback_function)  # With callback

        # Verify patterns were registered
        assert r'.*\.conf$' in monitor.Pattern._Pattern__patterns
        assert r'.*\.py$' in monitor.Pattern._Pattern__patterns

        # Verify callback function was assigned correctly
        conf_pattern = monitor.Pattern._Pattern__patterns[r'.*\.conf$']
        py_pattern = monitor.Pattern._Pattern__patterns[r'.*\.py$']

        # Default callback returns None
        assert conf_pattern.fn("test.conf", None) is None
        # Custom callback returns processed string
        assert py_pattern.fn("test.py", None) == "Processed test.py"


class TestHandler:
    files: set = set()

    def callback_function(self, path, cls):
        TestHandler.files |= set(path)

    def test_file_change_detection(self):
        """Test that file changes are detected and handled correctly"""
        TestHandler.files = set()
        monitor.Pattern(r'.*\.conf$')
        monitor.Pattern(r'.*\.py$', self.callback_function)

        handler = monitor.Handler()

        handler.dispatch(MockEvent("config.conf"))
        handler.dispatch(MockEvent("script.py"))
        handler.dispatch(MockEvent("document.txt"))

        assert "config.conf" in monitor.Handler._Handler__history
        assert "script.py" in monitor.Handler._Handler__history
        assert "document.txt" not in monitor.Handler._Handler__history
        assert monitor.Handler._Handler__doReboot is True

    # @patch('time.time')
    def test_reboot_no_triggering(self):
        """Test that reboot is triggered after file changes"""

        with patch('watchdog.observers.Observer'), \
                patch.object(monitor.fn, 'reboot_app') as mock_reboot:

            TestHandler.files = set()

            monitor.Pattern(r'.*\.py$', self.callback_function)
            handler = monitor.Handler()

            handler.dispatch(MockEvent("xpto/.git/abcd"))
            assert monitor.Handler._Handler__cont == 0

            handler.dispatch(MockEvent("xpto/.gitignore"))
            assert monitor.Handler._Handler__cont == 0

            handler.dispatch(MockEvent("script.txt"))
            assert monitor.Handler._Handler__cont == 1
            assert monitor.Handler._Handler__doReboot == False

    def test_reboot_triggering(self):
        """Test that reboot is triggered after file changes"""
        with patch('watchdog.observers.Observer'), \
                patch.object(monitor.fn, 'reboot_app') as mock_reboot:

            TestHandler.files = set()

            monitor.Pattern(r'.*\.py$', self.callback_function)
            handler = monitor.Handler()

            handler.dispatch(MockEvent("script.py"))
            assert monitor.Handler._Handler__cont == 1

            result = monitor.Handler.check_reboot()
            assert monitor.Handler._Handler__doReboot

            monitor.Handler.max_time = 0
            result = monitor.Handler.check_reboot()
            assert result is True  # Reboot happened
            assert monitor.Handler._Handler__doReboot is None  # Reboot flag reset
            assert "script.py" in TestHandler.files  # Callback was called
            mock_reboot.assert_called_once()  # reboot_app was called

    @patch('os.path.exists', return_value=True)
    def test_monitor_start(self, mock_exists):
        """Test starting the file monitoring process"""
        with patch('watchdog.observers.Observer') as mock_observer_class, \
                patch('time.sleep') as mock_sleep, \
                patch.object(monitor.Handler, 'check_reboot', side_effect=[False, True]), \
                patch('builtins.quit'), \
                patch('sys.exit'):  # Patch quit() and exit() to prevent SystemExit

            mock_observer = MagicMock()
            mock_observer_class.return_value = mock_observer

            original_observer = monitor.Handler._Handler__observer
            monitor.Handler._Handler__observer = mock_observer

            try:
                monitor.Handler.start()

                assert mock_observer.start.called
                assert mock_observer.schedule.called
                assert mock_sleep.called
                assert mock_observer.stop.called
                assert mock_observer.join.called
            finally:
                # Restore original observer
                monitor.Handler._Handler__observer = original_observer

    def test_keyboard_interrupt_handling(self):
        """Test handling of keyboard interrupt during monitoring"""
        with patch('watchdog.observers.Observer') as mock_observer_class, \
                patch('time.sleep', side_effect=KeyboardInterrupt), \
                patch.object(monitor.Logger, 'info') as mock_log_info, \
                patch('builtins.quit'), \
                patch('sys.exit'):  # Patch built-in quit function and exit

            mock_observer = MagicMock()
            mock_observer_class.return_value = mock_observer
            original_observer = monitor.Handler._Handler__observer
            monitor.Handler._Handler__observer = mock_observer

            try:
                monitor.Handler.start()

                mock_log_info.assert_any_call('End monitor')
                assert mock_observer.stop.called
                assert mock_observer.join.called
            finally:
                monitor.Handler._Handler__observer = original_observer

    def test_combined_workflow(self):
        """Test the complete workflow from pattern registration to file change handling"""
        with patch('time.time', side_effect=[1000, 1000, 1003]), \
                patch.object(monitor.fn, 'reboot_app') as mock_reboot:

            TestHandler.files = set()

            monitor.Pattern(r'.*\.conf$')
            monitor.Pattern(r'.*\.py$', self.callback_function)

            handler = monitor.Handler()

            handler.dispatch(MockEvent("config.conf"))
            handler.dispatch(MockEvent("script.py"))

            result = monitor.Handler.check_reboot()

            assert result is True
            assert "script.py" in TestHandler.files
            assert len(TestHandler.files) == 1
            mock_reboot.assert_called_once()

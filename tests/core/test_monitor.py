# test_monitor.py
import pytest
import re
import time
import os
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

        assert result == data

    def test_match_without_match(self):
        """Test match method with no matching pattern"""
        self.reset()
        monitor.Pattern(r"^/other/path")

        result = monitor.Pattern.match("/test/path/file.txt")

        assert result is None

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
    def test_file_change_detection(self):
        """Test that file changes are detected and handled correctly"""
        # Define a test callback that tracks calls
        callback_calls = []

        def test_callback(path, cls):
            callback_calls.append(path)

        # Register patterns
        monitor.Pattern(r'.*\.conf$')
        monitor.Pattern(r'.*\.py$', test_callback)

        # Create a handler instance
        handler = monitor.Handler()

        # Simulate file changes
        handler.dispatch(MockEvent("config.conf"))
        handler.dispatch(MockEvent("script.py"))
        # Should not match any pattern
        handler.dispatch(MockEvent("document.txt"))

        # Check that the correct paths were added to history
        assert "config.conf" in monitor.Handler._Handler__history
        assert "script.py" in monitor.Handler._Handler__history
        assert "document.txt" not in monitor.Handler._Handler__history

        # Verify reboot flag is set
        assert monitor.Handler._Handler__doReboot is True

    @patch('time.time')
    def test_reboot_triggering(self, mock_time):
        """Test that reboot is triggered after file changes"""
        # Set up time sequence
        # Initial, add_item, check_reboot
        mock_time.side_effect = [1000, 1000, 1003]

        # Mock reboot_app function
        with patch('watchdog.observers.Observer'), \
                patch.object(monitor.fn, 'reboot_app') as mock_reboot:

            # Register patterns
            callback_calls = []

            def test_callback(path, cls):
                callback_calls.append(path)

            monitor.Pattern(r'.*\.py$', test_callback)

            # Simulate file change
            handler = monitor.Handler()
            handler.dispatch(MockEvent("script.py"))

            # Check reboot (should happen because time difference > max_time)
            result = monitor.Handler.check_reboot()

            # Verify results
            assert monitor.Handler._Handler__doReboot

            monitor.Handler.max_time = 0
            result = monitor.Handler.check_reboot()
            assert result is True  # Reboot happened
            assert monitor.Handler._Handler__doReboot is None  # Reboot flag reset
            assert "script.py" in callback_calls  # Callback was called
            mock_reboot.assert_called_once()  # reboot_app was called

    # @patch('os.path.exists', return_value=True)
    # def test_monitor_start(self, mock_exists):
        # """Test starting the file monitoring process"""
        # with patch('watchdog.observers.Observer') as mock_observer_class, \
        #         patch('time.sleep') as mock_sleep, \
        #         patch.object(monitor.Handler, 'check_reboot', side_effect=[False, True]):

        #     # Create mock observer
        #     mock_observer = MagicMock()
        #     mock_observer_class.return_value = mock_observer

        #     # Start monitoring
        #     monitor.Handler.start()
        #     # Verify observer was set up correctly
        #     assert mock_observer.start.called
        #     assert mock_observer.schedule.called
        #     assert mock_sleep.called
        #     assert mock_observer.stop.called
        #     assert mock_observer.join.called

    # def test_keyboard_interrupt_handling(self):
        # """Test handling of keyboard interrupt during monitoring"""
        # with patch('watchdog.observers.Observer') as mock_observer_class, \
        #         patch('time.sleep', side_effect=KeyboardInterrupt), \
        #         patch.object(monitor.Handler._Handler__log, 'info') as mock_log_info:

        #     # Create mock observer
        #     mock_observer = MagicMock()
        #     mock_observer_class.return_value = mock_observer

        #     # Start monitoring (should exit due to KeyboardInterrupt)
        #     monitor.Handler.start()

        #     # Verify observer was stopped properly
        #     mock_log_info.assert_any_call('End monitor')
        #     assert mock_observer.stop.called
        #     assert mock_observer.join.called

    # def test_combined_workflow(self):
        # """Test the complete workflow from pattern registration to file change handling"""
        # # Set up time sequence
        # with patch('time.time', side_effect=[1000, 1000, 1003]), \
        #         patch.object(monitor.fn, 'reboot_app') as mock_reboot:

        #     # Define callback function
        #     processed_files = []

        #     def callback_function(path, cls):
        #         processed_files.append(path)

        #     # Register patterns
        #     monitor.Pattern(r'.*\.conf$')
        #     monitor.Pattern(r'.*\.py$', callback_function)

        #     # Create handler
        #     handler = monitor.Handler()

        #     # Simulate file changes
        #     handler.dispatch(MockEvent("config.conf"))
        #     handler.dispatch(MockEvent("script.py"))

        #     # Check reboot
        #     result = monitor.Handler.check_reboot()

        #     # Verify results
        #     assert result is True
        #     assert "script.py" in processed_files
        #     assert len(processed_files) == 1  # Only .py files trigger callback
        #     mock_reboot.assert_called_once()

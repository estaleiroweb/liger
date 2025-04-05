import argparse

commands = ['init', 'run', 'web', 'monitor']


def init(parser: argparse.ArgumentParser):
    """Initializes a new project."""
    parser.add_argument(
        "-f",
        "--force",
        help="Force rewrite.",
        default=None,
    )
    parser.add_argument(
        "-q",
        "--quite",
        action='store_true',
        help="Don't ask quetions.",
    )
    parser.add_argument(
        "-p",
        "--path",
        help="Path for the project (optional). Defaults to current directory.",
        default=None,
    )
    parser.add_argument(
        "-n",
        "--name",
        help="Name of project.",
        default=None,
    )
    parser.add_argument(
        "-k",
        "--secret",
        help="Secret key for the project (optional). Defaults to auto-generated.",
        default=None,
    )


def run(parser: argparse.ArgumentParser):
    """Executes a project class from the command line."""
    parser.add_argument(
        "class_name",
        help="The name of the class to execute.")


def web(parser: argparse.ArgumentParser):
    """Starts a web server based on web.json and monitors for configuration changes."""
    pass


def monitor(parser: argparse.ArgumentParser):
    """Monitors DSN connections to automate reverse engineering."""
    parser.add_argument(
        "-p",
        "--path",
        help="Path for the project (optional). Defaults to current directory.",
        default=None,
    )

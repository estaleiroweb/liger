import argparse
import importlib
from .admin import options


def main():
    """Main function to handle command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Application with init, web, monitor, and run options.")
    subparsers = parser.add_subparsers(
        dest="command",
        help="Command to execute.")

    for i in options.commands:
        o = options.__dict__[i]
        o(subparsers.add_parser(i, help=o.__doc__))

    args: argparse.Namespace = parser.parse_args()

    if args.command:
        try:
            init_module = importlib.import_module(
                f".admin.{args.command}", package=__package__)
            init_module.Main(args)  # Pass the parsed arguments to the module
        except ImportError as e:
            print(f"ERROR: 'admin/{args.command}.py' module not load.")
            print(e)
            quit()
    else:
        parser.print_help()  # Display help if no command is provided


if __name__ == "__main__":
    main()

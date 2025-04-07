
def main():
    """Main function to handle command-line arguments."""
    import sys
    import argparse
    import importlib
    from .admin import options
    from .core import fn
    from pathlib import Path

    fn.__BASE_DIR__ = Path.cwd()
    called_script = Path(sys.argv[0]).resolve()

    if called_script.name == "__main__.py":
        # Ex: .../site-packages/nomedopacote/__main__.py → nome do pacote = nomedopacote
        package_dir = called_script.parent
        package_name = package_dir.name
        fn.__BASE_ARGS__ = ["-m", package_name] + sys.argv[1:]
    else:
        fn.__BASE_ARGS__ = sys.argv[:]
    
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

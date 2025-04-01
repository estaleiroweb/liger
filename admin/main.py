import argparse
import importlib


def main():
    """Main function to handle command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Application with init, web, and monitor options.")

    parser.add_argument("command",
                        choices=["init", "web", "monitor", "run"],
                        help="Command to execute.")

    args = parser.parse_args()

    try:
        modulo_init = importlib.import_module(args.comando)
        modulo_init.main()
    except ImportError:
        print(f"ERROR: '{args.comando}.py' module not found.")
        quit()


if __name__ == "__main__":
    main()

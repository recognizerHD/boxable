#!/usr/bin/env python3
import argparse
import sys


def main():
    sys.stdout.write("\nBashSim>> ")
    command = input()
    arguments = command.split(" ")
    script = ""
    params = []
    scr = ""

    mainparser = argparse.ArgumentParser()
    subparser = mainparser.add_subparsers(dest="subcommand")
    parser = subparser.add_parser('')

    if len(arguments) > 0:
        script = arguments[0]
        params = arguments
        scr = params.pop(0)

    print(scr)
    print(script)
    print(params)


if __name__ == "__main__":
    main()

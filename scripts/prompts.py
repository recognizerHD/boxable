#!/usr/bin/env python3
import sys


class Prompts:
    YES = "yes"
    NO = "no"
    CANCEL = "cancel"

    @staticmethod
    def query_yes_no(question, default="yes"):
        """Ask a yes/no question via input() and return their answer.

            "question" is a string that is presented to the user.
            "default" is the presumed answer if the user just hits <Enter>.
                It must be "yes" (the default), "no" or None (meaning
                an answer is required of the user).

            The "answer" return value is True for "yes" or False for "no".
            """
        valid = {"yes": Prompts.YES, "y": Prompts.YES, "ye": Prompts.YES,
                 "no": Prompts.NO, "n": Prompts.NO}
        if default is None:
            prompt = " [y/n] "
        elif default == "yes":
            prompt = " [Y/n] "
        elif default == "no":
            prompt = " [y/N] "
        else:
            raise ValueError("invalid default answer: '%s'" % default)

        while True:
            sys.stdout.write(question + prompt)
            choice = input().lower()
            if default is not None and choice == '':
                return valid[default]
            elif choice in valid:
                return valid[choice]
            else:
                sys.stdout.write("Please respond with 'yes' or 'no' "
                                 "(or 'y' or 'n').\n")

    @staticmethod
    def query_yes_no_cancel(question, default="yes"):
        """Ask a yes/no question via input() and return their answer.

            "question" is a string that is presented to the user.
            "default" is the presumed answer if the user just hits <Enter>.
                It must be "yes" (the default), "no" or None (meaning
                an answer is required of the user).

            The "answer" return value is True for "yes" or False for "no".
            """
        valid = {"yes": Prompts.YES, "y": Prompts.YES, "ye": Prompts.YES,
                 "no": Prompts.NO, "n": Prompts.NO,
                 "cancel": Prompts.CANCEL, "c": Prompts.CANCEL, "ca": Prompts.CANCEL, "can": Prompts.CANCEL}
        if default is None:
            prompt = " [y/n/c] "
        elif default == "yes":
            prompt = " [Y/n/c] "
        elif default == "no":
            prompt = " [y/N/c] "
        elif default == "cancel":
            prompt = " [y/n/C] "
        else:
            raise ValueError("invalid default answer: '%s'" % default)

        while True:
            sys.stdout.write(question + prompt)
            choice = input().lower()
            if default is not None and choice == '':
                return valid[default]
            elif choice in valid:
                return valid[choice]
            else:
                sys.stdout.write("Please respond with 'yes' or 'no' or 'cancel' "
                                 "(or 'y' or 'n' or 'c').\n")

    @staticmethod
    def multi_choice(question, options, default="1"):
        if not isinstance(options, dict):
            return False

        while True:
            sys.stdout.write(question+"\n")
            for key, option in options.items():
                sys.stdout.write('[' + key + ']: ' + option['name']+"\n")
            choice = input().lower()
            if default is not None and choice == '':
                return options[default]
            elif choice in options:
                return options[choice]['value']
            else:
                sys.stdout.write("Please respond with one of the options.\n")

#!/usr/bin/env python3
import os
import platform
import shutil
import sys
from pathlib import Path

import yaml

from scripts import BoxLog, Prompts


class BoxBack:
    logger: BoxLog

    def __init__(self):
        BoxBack.setup()
        [config_file, config_path] = BoxBack.getfile()
        config = yaml.safe_load(open(config_file, 'r'))
        self.logger = BoxLog()

    @staticmethod
    def getfile():
        if os.name == 'nt':
            config_file = Path('D:/_dev/minionfactory/boxable/etc/boxable.yml')
            config_path = Path('D:/_dev/minionfactory/boxable/etc/boxables/')
        else:
            config_file = Path('/etc/boxable/boxable.yml')
            config_path = Path('/etc/boxable/boxables/')
        return [config_file, config_path]

    @staticmethod
    def setup():
        [config_file, config_path] = BoxBack.getfile()
        logger = BoxLog()

        if not os.path.exists(config_path):
            os.makedirs(config_path, exist_ok=True)

        if not config_file.is_file():
            directory = os.path.dirname(config_file)
            if not os.path.exists(directory):
                os.makedirs(directory, exist_ok=True)

            backup_destinations = {'1': {'value': 'google', 'name': 'Google Drive'},
                                   '2': {'value': 'dropbox', 'name': 'Dropbox'},
                                   'c': {'value': 'cancel', 'name': 'Cancel'}}
            choice = Prompts.multi_choice("Select the backup destination/driver.", backup_destinations)

            system = platform.system().lower()
            arch = platform.architecture()[0]

            if choice == "google":
                if shutil.which('gdrive') is None:
                    # Install google drive
                    if arch == '64bit' and system == 'windows':
                        file = "gdrive-windows-x64.exe"
                    elif arch == '32bit' and system == 'windows':
                        file = "gdrive-windows-386.exe"
                    elif arch == '64bit' and system == 'linux':
                        file = "gdrive-linux-x64"
                    elif arch == '32bit' and system == 'linux':
                        file = "gdrive-linux-386"
                    else:
                        logger.error("Boxable hasn't been developed for other systems at this time.")
                        sys.stdout.write("No supported systems\n")
                        return

                    data = dict(
                        method="google",
                        process=file
                    )

                    sys.stdout.write("The setup will now setup the authorization for google drive.\n")
                    # from subprocess import call
                    # rc = call(["gdrive", "list"], shell=False)
                    # if rc == 0:
                    #     print("someone is using zsh/ksh/tcsh")
                    # elif rc == 1:
                    #     print("zsh/ksh/tcsh not used")
                    # else:
                    #     print("an error occured, grep returned %d" % rc)

                    # Then prompt for folder, just paste, it can parse it.
                    # Save config.


            elif choice == "firebase":
                print("NOT YET")
                return
            elif choice == "dropbox":
                print("NOT YET")
                return
            elif choice == "cancel":
                return
            else:
                logger.error("Invalid option: " + choice + " for backup destination. Aborting.")
                sys.stdout.write("Invalid option. Aborting.\n")
                return

            # input_hostname = ''
            # input_port = ''
            # while input_hostname == '':
            #     user_input = input("Enter the host name: ")
            #     choice = Prompts.query_yes_no_cancel("Set the host to " + user_input)
            #     if choice == Prompts.CANCEL:
            #         exit()
            #     elif choice == Prompts.YES:
            #         input_hostname = user_input
            #
            # while input_port == '':
            #     user_input = int(input("Enter the port number: "))
            #     choice = Prompts.query_yes_no_cancel("Set the port to " + str(user_input))
            #     if choice == Prompts.CANCEL:
            #         exit()
            #     elif choice == Prompts.YES:
            #         input_port = user_input
            #
            # data = dict(
            #     hostname=input_hostname,
            #     port=input_port
            # )
            # with open(config_file, 'w') as config_out:
            #     yaml.dump(data, config_out)

    def backup(self, site, backup_type):
        print(site)
        print(backup_type)

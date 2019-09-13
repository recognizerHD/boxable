#!/usr/bin/env python3
import os
import platform
import re
import sys
from pathlib import Path
from subprocess import call, check_output
from typing import Dict, List, Any, Union, Hashable

import yaml

from scripts import BoxLog, Prompts


class BoxBack:
    logger: BoxLog

    def __init__(self):
        BoxBack.setup()
        [config_file, config_path] = BoxBack.getfile()
        self.config = yaml.safe_load(open(config_file, 'r'))
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
                # if shutil.which('gdrive') is None:
                # Decided to include gdrive.
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
                    exit()

                data = dict(
                    method="google",
                    process=file
                )

                sys.stdout.write("The setup will now setup the authorization for google drive.\n")

                while True:
                    response = call(["gdrive", "list"], shell=False)
                    if response == 0:
                        break
                    elif response == 1:
                        choice = Prompts.query_yes_no("An error has occurred. Try again?")
                        if choice == Prompts.NO:
                            exit()
                    else:
                        print("An error occurred, gdrive returned %d" % response)

                while True:
                    destination_folder = input("Paste the destination folder you wish backup files to reside.\nGoogle Drive: ")
                    result = re.search(r"^(https://.*/folders/)?([^/]*?)$", destination_folder)
                    if result is not None:
                        destination_folder = result.group(2)

                    test = call(["gdrive", "info", destination_folder])
                    if test == 0:
                        google_folder = check_output(["gdrive", "info", destination_folder])
                        google_yaml = yaml.safe_load(google_folder)

                        choice = Prompts.query_yes_no_cancel("Set the folder to " + google_yaml["Name"] + " [" + google_yaml['Id'] + "]")
                        if choice == Prompts.CANCEL:
                            exit()
                        elif choice == Prompts.YES:
                            break
                    else:
                        choice = Prompts.query_yes_no("An error has occurred. Try again?")
                        if choice == Prompts.NO:
                            exit()

                data['destination'] = destination_folder

                choice = Prompts.query_yes_no("Create folder for each site?")
                if choice == Prompts.YES:
                    data['create_site_folders'] = True
                else:
                    data['create_site_folders'] = False

                with open(config_file, 'w') as config_out:
                    yaml.dump(data, config_out)
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

    def backup(self, site, backup_type):
        """
        if site is defined,
            add site to config list
        Else
            read etc/boxables folder and add each file into sites

        loop over sites and
            get folders / files to add and add them to zip file
            ( based on backup_type )
        backup each database in the config
            add them to zip
        get path to upload files to
            
        """
        sites = []

        configs = os.listdir('etc/boxables')
        print(site)
        print(backup_type)

    def upload(self, method, file):
        if method == 'google':
            print("upload "+file)

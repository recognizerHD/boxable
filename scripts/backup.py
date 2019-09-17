#!/usr/bin/env python3
import gzip
import os
import platform
import re
import shutil
import sys
import tarfile
from datetime import date
from pathlib import Path
from subprocess import call, check_output

import yaml

from scripts import BoxLog, Prompts


class BoxBack:
    logger: BoxLog
    backup_folder = "archive"
    file_list = dict()
    sites = []

    def __init__(self):
        BoxBack.setup()
        [config_file, config_path] = BoxBack.getfile()
        self.config = yaml.safe_load(open(config_file, 'r'))
        self.logger = BoxLog()
        self.file_list = self.read_destination(self.config["method"], self.config["destination"])

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
                    uploader = "bin/gdrive-windows-x64.exe"
                elif arch == '32bit' and system == 'windows':
                    uploader = "bin/gdrive-windows-386.exe"
                elif arch == '64bit' and system == 'linux':
                    uploader = "bin/gdrive-linux-x64"
                elif arch == '32bit' and system == 'linux':
                    uploader = "bin/gdrive-linux-386"
                else:
                    logger.error("Boxable hasn't been developed for other systems at this time.")
                    sys.stdout.write("No supported systems\n")
                    exit()

                data = dict(
                    method="google",
                    process=uploader
                )

                sys.stdout.write("The setup will now setup the authorization for google drive.\n")

                while True:
                    response = call([uploader, "list"], shell=False)
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

                    test = call([uploader, "info", destination_folder])
                    if test == 0:
                        google_folder = check_output([uploader, "info", destination_folder])
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
        loop over sites and
            get folders / files to add and add them to zip file
            ( based on backup_type )
        backup each database in the config
            add them to zip
        get path to upload files to
        :return:
        """

        self.sites = []
        [uneeded, config_path] = self.getfile()
        configs = os.listdir(config_path)
        today = date.today()
        today.isoformat()
        for key, config in configs:
            if os.path.splitext(config)[1] == 'yaml':
                if site == "*" or site == os.path.splitext(config)[0]:
                    site_object = dict(
                        tar_file=self.backup_folder + "/tar/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar",
                        zip_file=self.backup_folder + "/0/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar.gz",
                        site_name=os.path.splitext(config)[0],
                        config=config_path + config
                    )
                    self.sites.append(site_object)

        if site == "*":
            if backup_type == "inc":
                message = "Running an incremental backup on all sites."
            else:
                message = "Running a full backup on all sites."
        else:
            if backup_type == "inc":
                message = "Running an incremental backup on " + site
            else:
                message = "Running a full backup on " + site
        print(message + "\n")
        self.logger.info(message)

        self.shuffle_backups()
        for site in self.sites:
            self.create_archive(site)
            self.upload(self.config["method"], site)

    def shuffle_backups(self):
        # 1. Delete backup/archive/3. Move 2->3, 1->2, working->1.
        if not os.path.exists(self.backup_folder):
            os.makedirs(self.backup_folder, exist_ok=True)
        if os.path.exists(self.backup_folder + "/3"):
            shutil.rmtree(self.backup_folder + "/3", True)
        if os.path.exists(self.backup_folder + "/2/"):
            os.rename(self.backup_folder + "/2", self.backup_folder + "/3")
        if os.path.exists(self.backup_folder + "/1/"):
            os.rename(self.backup_folder + "/1", self.backup_folder + "/2")
        if os.path.exists(self.backup_folder + "/0/"):
            os.rename(self.backup_folder + "/0", self.backup_folder + "/1")
        if not os.path.exists(self.backup_folder + "/0/"):
            os.makedirs(self.backup_folder + "/0/", exist_ok=True)

    def create_archive(self, site):
        if os.path.exists(self.backup_folder + "/sql"):
            shutil.rmtree(self.backup_folder + "/sql", True)
        os.makedirs(self.backup_folder + "/sql", exist_ok=True)
        if os.path.exists(self.backup_folder + "/tar"):
            shutil.rmtree(self.backup_folder + "/tar", True)
        os.makedirs(self.backup_folder + "/tar", exist_ok=True)
        tar_file = site["tar_file"]
        zip_file = site["zip_file"]
        config_file = site["config"]
        tar = tarfile.open(tar_file, "w")
        boxable_config = yaml.safe_load(open(config_file, 'r'))
        root = boxable_config["home"]

        if isinstance(boxable_config["files"], list):
            for item in boxable_config["files"]:
                if os.path.exists(root + item):
                    tar.add(root + item, "files/" + item)
        if isinstance(boxable_config["mysql"], list):
            for database in boxable_config["mysql"]:
                test = call(["/usr/bin/mysqldump", "--force", "--opt", "--skip-lock-tables", "--databases", database], shell=False)
                if test == 0:
                    sql = check_output(["/usr/bin/mysqldump", "--force", "--opt", "--skip-lock-tables", "--databases", database])
                    with open(self.backup_folder + "/sql/" + database + ".sql", "w") as sql_file:
                        sql_file.write(sql)
            tar.add(self.backup_folder + "/sql/", "sql")
        tar.close()

        with open(tar_file, "rb") as buffer, gzip.open(zip_file, "wb") as gz:
            gz.writelines(buffer)
        gz.close()
        os.remove(tar_file)

    def read_destination(self, method, destination):
        if method == 'google':
            uploader = self.config["process"]
            # create_folders = self.config["create_site_folders"]
            test = call([uploader, "list", "--name-width", "0", "-m", "200", "-q", "'" + destination + "' in parents"])
            if test == 0:
                raw_output = check_output([uploader, "list", "--name-width", "0", "-m", "300", "-q", "'" + destination + "' in parents"]).decode()
                matches = re.findall(r"(Id|.*?) {3,}(Name|.*?) {3,}(Type|.*?) {3,}(Size|.*?) {3,}(Created|\d{4}.*)?", raw_output)
                file_list = dict()
                for [id, name, type, size, created] in matches:
                    if id == 'Id':
                        continue

                    file_list[name] = dict(
                        id=id,
                        type=type
                    )
                return file_list

    def upload(self, method, site):
        zip_file = site["zip_file"]
        if method == 'google':
            uploader = self.config["process"]
            destination = self.config["destination"]
            create_folders = self.config["create_site_folders"]

            site_name = site["site_name"]
            if not create_folders:
                real_destination = destination
            else:
                if site_name in self.file_list.keys() and self.file_list.get(site_name['type'] == 'dir'):
                    real_destination = self.file_list.get(site_name)
                else:
                    response = check_output([uploader, "mkdir", site_name]).decode('utf-8')
                    real_destination = re.search("Directory (.*) created", response)[1]

            file_list = self.read_destination(method, real_destination)
            if len(file_list):
                for name, file in file_list:
                    if name == zip_file:
                        self.logger.info("Updating " + zip_file + " using " + uploader + " to " + method + ":" + real_destination)
                        call([uploader, "update", file["id"], zip_file])
                        return

            self.logger.info("Uploading " + zip_file + " using " + uploader + " to " + method + ":" + real_destination)
            call([uploader, "upload", "-p", real_destination, zip_file])

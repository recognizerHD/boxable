#!/usr/bin/env python3
import os
import re
from datetime import date

from scripts import BoxBack, BoxLog

destination_folder = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

string = "https://drive.google.com/drive/u/2/folders/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "fofasdf/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

result = re.search(r"^(https://.*/folders/)?([^/]*?)$", string)

if result is not None:
    print(result.group(2))

# Test the setup of BoxLog
BoxLog.setup()

# # test 1
# BoxBack.setup()

# # Test 2
backup = BoxBack()
# backup.shuffle_backups()

# # Test 3
today = date.today()
config = "ikonquest.com.yaml"
site_object = dict(
    tar_file="archi ve/tar/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar",
    zip_file="archive/0/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar.gz",
    site_name=os.path.splitext(config)[0],
    config="/etc/boxable/boxables/" + config
)
# backup.create_archive(site_object)

# Test 3.5
print(backup.file_list)

# # Test 4
# backup.upload("google", site_object)

# # Test 5
# backup.backup(os.path.splitext(config)[0], "inc")

# # Test 6
# backup.backup(os.path.splitext(config)[0], "full")

# # Test 7
# backup.backup("*", "full")


# tests = call(["bin/gdrive-windows-x64.exe", "info", destination_folder])
# if tests == 0:
#     google_folder = check_output(["bin/gdrive-windows-x64.exe", "info", destination_folder])
#     google_yaml = yaml.safe_load(google_folder)
#
#     print(google_yaml["Name"]+" ["+google_yaml['Id']+"]")

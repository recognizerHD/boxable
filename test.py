#!/usr/bin/env python3
import os
import re
from datetime import date

from scripts import BoxBack

destination_folder = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

string = "https://drive.google.com/drive/u/2/folders/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "fofasdf/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

result = re.search(r"^(https://.*/folders/)?([^/]*?)$", string)

if result is not None:
    print(result.group(2))

# # test 1
# BoxBack.setup()

# # Test 2
backup = BoxBack()
# backup.shuffle_backups()

# # Test 3
# today = date.today()
# config = "ikonquest.com.yaml"
# site_object = dict(
#     tar_file="archive/tar/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar",
#     zip_file="archive/0/" + os.path.splitext(config)[0] + "-" + today.isoformat() + ".tar.gz",
#     site=os.path.splitext(config)[0],
#     config="etc/boxables/" + config
# )
# backup.create_archive(site_object)

# # Test 4
# backup.upload("google",site_object)

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

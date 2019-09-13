#!/usr/bin/env python3
import re

destination_folder = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

string = "https://drive.google.com/drive/u/2/folders/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "0B7nAS5KVLBl4VmlhRDRQRzlrMmM"
# string = "fofasdf/0B7nAS5KVLBl4VmlhRDRQRzlrMmM"

result = re.search(r"^(https://.*/folders/)?([^/]*?)$", string)

if result is not None:
    print(result.group(2))
# tests = call(["bin/gdrive-windows-x64.exe", "info", destination_folder])
# if tests == 0:
#     google_folder = check_output(["bin/gdrive-windows-x64.exe", "info", destination_folder])
#     google_yaml = yaml.safe_load(google_folder)
#
#     print(google_yaml["Name"]+" ["+google_yaml['Id']+"]")

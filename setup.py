#!/usr/bin/env python3


# from scripts.prompts import *
import scripts

# Prompt = scripts.Prompts

# config = yaml.safe_load(open())

# create /etc/lempi folder

logger = scripts.BoxLog()
logger.error("OH NO!")
scripts.Prompts.query_yes_no("Is cabbage yummier than cauliflower?")

papertrail_server = input("TEST THIS")

# prompt for settings for papertrail.
# create /etc/lempi/logger.yml

# Structure
# https://docs.python-guide.org/writing/structure/

# IMporting:
# https://stackoverflow.com/questions/2349991/how-to-import-other-python-files
# https://stackoverflow.com/questions/279237/import-a-module-from-a-relative-path
# https://stackoverflow.com/questions/37233140/python-module-not-found

# Loading Configs:
# https://stackoverflow.com/questions/5055042/whats-the-best-practice-using-a-settings-file-in-python
# https://camel.readthedocs.io/en/latest/yamlref.html
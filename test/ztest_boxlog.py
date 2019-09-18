#!/usr/bin/env python3
import os
import unittest

import yaml

from src import BoxLog


class TestBoxLog(unittest.TestCase):
    def test_setup(self):
        config_file = BoxLog.getfile()
        if os.path.exists(config_file):
            rename = True
        else:
            rename = False

        if rename:
            os.rename(config_file, config_file + ".testing")

        BoxLog.setup()
        self.assertTrue(os.path.exists(config_file))
        config = yaml.safe_load(open(config_file, 'r'))
        self.assertTrue("hostname" in config.keys())

        if rename:
            os.rename(config_file + ".testing", config_file)

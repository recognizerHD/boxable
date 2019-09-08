#!/usr/bin/env python3
import logging
import os
import socket
import yaml
import sys
from pathlib import Path
from logging import Logger

from logging.handlers import SysLogHandler


class BoxLog:
    logger: Logger

    def __init__(self):
        if os.name = 'nt':
            self.config_path = Path('D:\_dev\minionfactory\boxable\etc\logger.yml')
        else:
            self.config_path = Path('/etc/boxable/logger.yml')

        config = yaml.safe_load(open(self.config_file))
        syslog = SysLogHandler(address=('logs4.papertrailapp.com', 35497))
        syslog.addFilter(ContextFilter())

        log_format = '%(asctime)s %(hostname)s LempB: %(message)s'
        formatter = logging.Formatter(log_format, datefmt='%b %d %H:%M:%S')
        syslog.setFormatter(formatter)

        self.logger = logging.getLogger()
        self.logger.addHandler(syslog)

    def debug(self, message):
        self.logger.debug(message)

    def info(self, message):
        self.logger.info(message)

    def warning(self, message):
        self.logger.warning(message)

    def error(self, message):
        self.logger.error(message)

    def critical(self, message):
        self.logger.critical(message)


class ContextFilter(logging.Filter):
    hostname = socket.gethostname()

    def filter(self, record):
        record.hostname = ContextFilter.hostname
        return True

# # logger.info(sys.argv[1:])
# if sys.argv[1:]:
#     logger.info(sys.argv[1])
# #    print(sys.argv[1])
# print(sys.argv[1:])

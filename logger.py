#!/usr/bin/env python2
import logging
import socket
import sys
from logging.handlers import SysLogHandler

class ContextFilter(logging.Filter):
    hostname = socket.gethostname()

    def filter(self, record):
        record.hostname = ContextFilter.hostname
        return True

syslog = SysLogHandler(address=('logs4.papertrailapp.com', 35497))
syslog.addFilter(ContextFilter())

format = '%(asctime)s %(hostname)s LempB: %(message)s'
formatter = logging.Formatter(format, datefmt='%b %d %H:%M:%S')
syslog.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(syslog)
logger.setLevel(logging.INFO)

# logger.info(sys.argv[1:])
if sys.argv[1:]:
    logger.info(sys.argv[1])
#    print(sys.argv[1])
# print(sys.argv[1:])
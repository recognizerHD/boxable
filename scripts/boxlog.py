#!/usr/bin/env python3
import logging
import os
import socket
import yaml
from pathlib import Path
from logging import Logger
from scripts.prompts import Prompts
from logging.handlers import SysLogHandler


class BoxLog:
    logger: Logger

    def __init__(self):
        BoxLog.setup()
        config_file = BoxLog.getfile()

        config = yaml.safe_load(open(config_file, 'r'))
        syslog = SysLogHandler(address=(config['hostname'], config['port']))
        syslog.addFilter(ContextFilter())

        log_format = '%(asctime)s %(hostname)s Boxable: %(message)s'
        formatter = logging.Formatter(log_format, datefmt='%b %d %H:%M:%S')
        syslog.setFormatter(formatter)

        self.logger = logging.getLogger()
        self.logger.addHandler(syslog)

        # self.logger.debug("Message debug")
        # self.logger.info("Message info")
        # self.logger.warning("Message warning")
        # self.logger.error("Message error")
        # self.logger.critical("Message critical")

    @staticmethod
    def getfile():
        if os.name == 'nt':
            config_file = Path('D:/_dev/minionfactory/boxable/etc/logger.yml')
        else:
            config_file = Path('/etc/boxable/logger.yml')
        return config_file

    @staticmethod
    def setup():
        config_file = BoxLog.getfile()

        if not config_file.is_file():
            directory = os.path.dirname(config_file)
            if not os.path.exists(directory):
                os.makedirs(directory, exist_ok=True)

            print("This uses Papertrail for logging. Please supply the necessary details or pick CANCEL when prompted to abort.")
            input_hostname = ''
            input_port = ''
            while input_hostname == '':
                user_input = input("Enter the host name: ")
                choice = Prompts.query_yes_no_cancel("Set the host to " + user_input)
                if choice == Prompts.CANCEL:
                    exit()
                elif choice == Prompts.YES:
                    input_hostname = user_input

            while input_port == '':
                user_input = int(input("Enter the port number: "))
                choice = Prompts.query_yes_no_cancel("Set the port to " + str(user_input))
                if choice == Prompts.CANCEL:
                    exit()
                elif choice == Prompts.YES:
                    input_port = user_input

            data = dict(
                hostname=input_hostname,
                port=input_port
            )
            with open(config_file, 'w') as config_out:
                yaml.dump(data, config_out)

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

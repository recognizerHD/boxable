#!/usr/bin/env python3
import sys

import scripts

backup = scripts.BoxBack()

if sys.argv[1:]:
    sites = "*"
    backup_type = "inc"
    for arg in sys.argv:
        if arg == "inc":
            backup_type = "inc"
        elif arg == "full":
            backup_type = "full"
        elif arg != "":
            sites = arg

    backup.backup(sites, backup_type)
    # logger.error(sys.argv[1])
# # logger.info(sys.argv[1:])
# #    print(sys.argv[1])
# print(sys.argv[1:])

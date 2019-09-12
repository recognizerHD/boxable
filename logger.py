#!/usr/bin/env python3
import sys
import scripts

logger = scripts.BoxLog()

if sys.argv[1:]:
    logger.error(sys.argv[1])
# # logger.info(sys.argv[1:])
# #    print(sys.argv[1])
# print(sys.argv[1:])

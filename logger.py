#!/usr/bin/env python3
import sys
import src

logger = src.BoxLog()

if sys.argv[1:]:
    logger.error(sys.argv[1])
# coding=utf-8
"""
Shrc Sys_path Module
"""
import os
import sys
from pathlib import Path
# FIXME: copied from Archive/shrc/etc/ipython

if os.getcwd() not in sys.path:
    sys.path = [os.getcwd()] + sys.path
if (src := Path.cwd() / "src").exists() and str(src) not in sys.path:
    sys.path = [str(src)] + sys.path

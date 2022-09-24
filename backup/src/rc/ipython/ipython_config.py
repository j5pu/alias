# coding=utf-8
"""
Shrc Ipython_config Module
"""

# FIXME: copied from Archive/shrc/etc/ipython

c.InteractiveShellApp.extensions = [
    "asynciomagic", "autoreload", "pyflyby", "restmagic", "rich"
]
c.InteractiveShellApp.exec_lines = ['%autoreload 2', "%rehashx", ]  # type: ignore[name-defined]
c.InteractiveShell.autoindent = True  # type: ignore[name-defined]
c.InteractiveShell.automagic = True    # type: ignore[name-defined]
c.TerminalIPythonApp.display_banner = False  # type: ignore[name-defined]
c.TerminalInteractiveShell.confirm_exit = False  # type: ignore[name-defined]

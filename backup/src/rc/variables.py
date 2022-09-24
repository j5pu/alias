# coding=utf-8
"""
Constants and Variables Module
"""
__all__ = (
    "IPYTHON",
    "IS_REPL",
)
import sys
from pathlib import Path

try:
    IPYTHON = get_ipython()  # type: ignore[name-defined]
    """
    Global :class:`IPython.core.interactiveshell.InteractiveShell` instance,
    None if no InteractiveShell instance is registered.
    """
except NameError:
    IPYTHON = None

IS_REPL = bool(IPYTHON) or hasattr(sys, 'ps1') or 'pythonconsole' in sys.stdout.__class__.__module__
"""True if running on REPL, otherwise False."""

LINUX = sys.platform == "linux"
"""Is Linux? sys.platform == 'linux'"""

MACOS = sys.platform == "darwin"
"""Is macOS? sys.platform == 'darwin'"""

PROJECT: str = Path(__file__).parent.name
"""Repository/PyPi/Homebrew Formula Project Name"""

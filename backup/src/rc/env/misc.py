# coding=utf-8
"""
System Environment Variables
"""
__all__ = (
  "COLORIZE",
)

from .utils import environment

COLORIZE: bool
"""
Forces showing or hiding colors and other styles colorized output.
To force hiding colors/styles in :class:`shrc.Color` and :class:`shrc.Symbol`, set this to either "False", "0", "off".
To force showing colors/styles in :class:`shrc.Color` and :class:`shrc.Symbol`, set this to either "True", "1", "on".
By default, click will remove color if the output does not look like an interactive terminal (default: variable unset)
"""

GITHUB_ACTION: str

environment()

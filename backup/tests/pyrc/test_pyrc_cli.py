# coding=utf-8
"""
Start
"""
# FIXME: copied from Archive/shrc/src/shrc

from mreleaser import cli_invoke
from pyrc.jetbrains import app


def test_help():
    """
    cli --help
    """
    result = cli_invoke(app, ["--help"])
    assert result.exit_code == 0
    assert result.output.startswith("Usage:")

# coding=utf-8
"""
src package
"""
# FIXME: copied from Archive/shrc/src/shrc
from .alias import *
from .color import *
from .constants import *
from .jetbrains import *
from .startup import *
from .utils import *
from .variables import *

from . import alias
from . import color
from . import constants
from . import env as env
from . import jetbrains
from . import startup
from . import utils
from . import variables

__all__ = \
    alias.__all__ + \
    color.__all__ + \
    constants.__all__ + \
    jetbrains.__all__ + \
    startup.__all__ + \
    utils.__all__ + \
    variables.__all__ + \
    ("env", )

if __name__ == "__main__":
    import typer
    from .jetbrains import app
    try:
        typer.Exit(app())
    except KeyboardInterrupt:
        print('Aborted!')
        typer.Exit()

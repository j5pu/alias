# coding=utf-8
"""
Startup Module

    Performs the following always when imported:
        - Aliases :func:`rich.inspect` as :func:`rich_inspect` for :class:`rich._inspect.Inspect`
        - Replaces :builtin:`print` with :rich:`rich.print`.
        - Imports: :func:`rich.print_json`
        - Patches :class:`rich.console.Console` to detect PyCharm console and other consoles.
        - Installs: :class:`rich.pretty.Pretty`.
        - Installs :class:`rich.traceback.Traceback`.
        - Installs :class:`rich.inspect.Inspect`.

    the following if running in a console:
        - Imports modules used in package
        - Set environment vars in :mod:``shrc.env``
        - Imports :class:`ghapi.all.GhApi` and initializes it with `GITHUB_TOKEN` environment variable.
        - Preprends current working dir and cwd/src if exists to :obj:`sys.path`

    and the following if running under iPython:
        - Supress :class:``UserWarning`` so using shell commands ! will not emit warnings.
        - Loads default extensions.
        - Changes values for magic modules: automagic and autoindent
        - Sets custom prompt with basename of current working directory.

Examples:
    >>> import time
    >>> from rich.json import JSON
    >>>
    >>> with console.status("Working...", spinner="material"):  # doctest: +SKIP
    ...    time.sleep(2)
    >>>
    >>> console.log(JSON('["foo", "bar"]'))  # doctest: +SKIP
    >>>
    >>> print_json('["foo", "bar"]')  # doctest: +SKIP
    >>>
    >>> console.log("Hello, World!")  # doctest: +SKIP
    >>> console.print([1, 2, 3])  # doctest: +SKIP
    >>> console.print("[blue underline]Looks like a link")  # doctest: +SKIP
    >>> console.print(locals())  # doctest: +SKIP
    >>> console.print("FOO", style="white on blue")  # doctest: +SKIP
    >>>
    >>> blue_console = Console(style="white on blue")  # doctest: +SKIP
    >>> blue_console.print("I'm blue. Da ba dee da ba di.")  # doctest: +SKIP
    >>>
    >>> console.input("What is [i]your[/i] [bold red]name[/]? :smiley: ")  # doctest: +SKIP


References:
    `IPython Configuration File <https://ipython.readthedocs.io/en/stable/config/intro.html>`_
    ~/.ipython/profile_default/startup/00-console.py
    ~/.ipython/profile_default/ipython_config.py

    ``c.InteractiveShellApp.extensions.extend(['autoreload', 'rich'])``
    or include
    ``%load_ext rich``

    Test with: `print("[italic red]Hello[/italic red] World!", locals())`

    `Rich Inspect <https://rich.readthedocs.io/en/stable/traceback.html?highlight=sitecustomize>`_

    ``rich.traceback.install(suppress=[click])``

    To see the spinners: `python -m rich.spinner`
    To print json from the comamand line: `python -m rich.json cats.json`

    `Rich Console <https://rich.readthedocs.io/en/stable/console.html>`_

    Input: `console.input("What is [i]your[/i] [bold red]name[/]? :smiley: ")`
"""
__all__ = (
    "print",
    "print_json",

    "Console",
    "console",
)
import rich.pretty
import rich.traceback
from rich import print
from rich import print_json

from .utils import is_terminal
from .utils import Noset
from .variables import IPYTHON
from .variables import IS_REPL


setattr(rich.console.Console, "is_terminal", is_terminal)
Console = rich.console.Console
console: Console = rich.console.Console()

NOSET = Noset()

if IS_REPL:
    __all__ += (
    )
    import os
    import sys
    from pathlib import Path

    from .env import *
    from . import env as env

    __all__ += env.__all__ + ("env",)

    if os.getcwd() not in sys.path:
        sys.path = [os.getcwd()] + sys.path
    if (src := Path.cwd() / "src").exists() and str(src) not in sys.path:
        sys.path = [str(src)] + sys.path

if IPYTHON:
    __all__ += (
        "IPYTHON",
    )

    import warnings

    from IPython.terminal.prompts import Prompts
    from IPython.terminal.prompts import Token

    warnings.filterwarnings("ignore", category=UserWarning)
    for extension in ["autoreload", "rich"]:
        if extension not in IPYTHON.extension_manager.loaded:
            IPYTHON.extension_manager.load_extension(extension)
    IPYTHON.autoindent = True
    IPYTHON.automagic = True  # % prefix IS NOT needed for line magics
    IPYTHON.banner1 = ""
    IPYTHON.banner2 = ""
    IPYTHON.find_line_magic("rehashx")("1")  # Update the alias table with all executable files in $PATH.

    class Prompt(Prompts):
        def in_prompt_tokens(self, cli=None):
            return [
                (Token, Path.cwd().name),
                (Token.Prompt, "["),
                (Token.PromptNum, str(self.shell.execution_count)),
                (Token.Prompt, "]: "),
            ]
    IPYTHON.prompts = Prompt(IPYTHON)

rich.pretty.install(expand_all=True)
rich.traceback.install(show_locals=True, suppress=["click", "_pytest", "rich"])


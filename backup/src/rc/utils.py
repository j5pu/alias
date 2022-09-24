# coding=utf-8
"""
Utils Module
"""
__all__ = (
    "GhApi",
    "Noset",
    "TempDir",

    "aioclone",
    "aiocmd",
    "aiodmg",
    "aiogz",
    "ami",
    "clone",
    "cmd",
    "dmg",
    "github_url",
    "gz",
    "is_terminal",
    "python_latest",
    "python_version",
    "python_versions",
    "syssudo",
    "tardir",
    "tilde",
)

import asyncio
import getpass
import os
import platform
import pwd
import re
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path
from subprocess import CompletedProcess
from typing import Any

import bs4
import ghapi.all
import requests
import rich
import rich.console
import rich.pretty
import rich.traceback
from mreleaser import aiocmd
from mreleaser import cmd
from mreleaser import CmdError
from semver import VersionInfo

from .constants import GIT_DEFAULT_SCHEME
from .constants import GITHUB_URL
from .constants import GitScheme
from .constants import PYTHON_FTP
from .variables import IS_REPL
from .variables import PROJECT


# TODO: aqui lo dejo: https://docs.python.org/3/library/importlib.html
#  meter esas dos funciones y limpiar el pretty y ver que hago con el sitecustomize.py


class GhApi(ghapi.all.GhApi):
    """:class:`ghapi.all.GhApi` with some customizations for :mod:`shrc.env`."""
    def __init__(self, owner=None, repo=None, token=None, debug=None, limit_cb=None, **kwargs):
        if owner is None:
            from .env import GIT
            from .env import USER
            owner = owner or GIT or USER
        if token is None:
            from .env import GH_TOKEN
            from .env import GITHUB_TOKEN
            from .env import TOKEN
            token = token or GH_TOKEN or GITHUB_TOKEN or TOKEN
        super().__init__(owner=owner, repo=repo or PROJECT, token=token, debug=debug, limit_cb=limit_cb, **kwargs)


class Noset:
    """
    Marker object for globals not initialized or other objects.

    Examples:
        >>> from shrc.startup import NOSET
        >>> name = Noset.__name__.lower()
        >>> assert str(NOSET) == f'<{name}>'
        >>> assert repr(NOSET) == f'<{name}>'
        >>> assert repr(Noset("test")) == f'<test>'
    """
    name: str
    __slots__ = ("name",)
    def __init__(self, name: str = ""): self.name = name if name else self.__class__.__name__.lower()
    def __hash__(self): return hash((self.__class__, self.name,))
    def __reduce__(self): return self.__class__, (self.name,)
    def __repr__(self): return self.__str__()
    def __str__(self): return f'<{self.name}>'


async def aioclone(owner: str | None = None, repo: str = PROJECT, scheme: GitScheme = GIT_DEFAULT_SCHEME,
                   path: Path | str = None) -> CompletedProcess:
    """
    Async Clone Repository

    Examples:
        >>> with TempDir() as tmp:
        ...     directory = tmp / "1" / "2" / "3"
        ...     rv = asyncio.run(aioclone("octocat", "Hello-World", path=directory))
        ...     assert rv.returncode == 0
        ...     assert (directory / "README").exists()

    Args:
        owner: github owner, None to use GIT or USER environment variable if not defined (Default: `GIT`)
        repo: github repository (Default: `PROJECT`)
        scheme: url scheme (Default: "https")
        path: path to clone (Default: `repo`)

    Returns:
        CompletedProcess
    """
    path = path or Path.cwd() / repo
    path = Path(path)
    if not path.exists():
        if not path.parent.exists():
            path.parent.mkdir(parents=True)
        return await aiocmd("git", "clone", github_url(owner, repo, scheme), path)


async def aiodmg(src: Path | str, dest: Path | str) -> None:
    """
    Async Open dmg file and copy the app to dest

    Examples:
        # >>> await dmg(Path("/tmp/JetBrains.dmg"), Path("/tmp/JetBrains"))

    Args:
        src: dmg file
        dest: path to copy to

    Returns:
        CompletedProcess
    """
    with TempDir() as tmpdir:
        await aiocmd("hdiutil", "attach", "-mountpoint", tmpdir, "-nobrowse", "-quiet", src)
        for item in src.iterdir():
            if item.name.endswith(".app"):
                await aiocmd("cp", "-r", tmpdir / item.name, dest)
                await aiocmd("xattr", "-r", "-d", "com.apple.quarantine", dest)
                await aiocmd("hdiutil", "detach", tmpdir, "-force")
                break


async def aiogz(src: Path | str, dest: Path | str = ".") -> Path:
    """
    Async ncompress .gz src to dest (default: current directory)

    It will be uncompressed to the same directory name as src basename.
    Uncompressed directory will be under dest directory.

    Examples:
        >>> await aiogz("test.tar.gz", "/tmp")  # doctest: +SKIP
        PosixPath('/tmp/test')
        >>>
        >>> cwd = Path.cwd()
        >>> with TempDir() as workdir:
        ...     os.chdir(workdir)
        ...     with TempDir() as compress:
        ...         file = compress / "test.txt"
        ...         file.touch()  # doctest: +ELLIPSIS
        ...         compressed = tardir(compress)
        ...         with TempDir() as uncompress:
        ...             uncompressed = asyncio.run(aiogz(compressed, uncompress))
        ...             assert uncompressed.is_dir()
        ...             assert Path(uncompressed).joinpath(file.name).exists()
        >>> os.chdir(cwd)

    Args:
        src: file to uncompress
        dest: destination directory to where uncompress directory will be created (default: current directory)

    Returns:
        Absolute Path of the Uncompressed Directory
    """
    return await asyncio.to_thread(gz, src, dest)


def ami(user: str = "root") -> bool:
    """
    Check if Current User is User in Argument (default: root)

    Examples:
        >>> ami(os.getenv("USER"))
        True
        >>> ami()
        False

    Arguments:
        user: to check against current user (Default: False)

    Returns:
        CompletedProcess if the current user is not the same as user, None otherwise
    """
    return os.getuid() == pwd.getpwnam(user or getpass.getuser()).pw_uid


def clone(owner: str | None = None, repo: str = PROJECT, scheme: GitScheme = GIT_DEFAULT_SCHEME,
          path: Path | str = None) -> CompletedProcess | None:
    """
    Clone Repository

    Examples:
        >>> with TempDir() as tmp:
        ...     directory = tmp / "1" / "2" / "3"
        ...     rv = clone("octocat", "Hello-World", "git+ssh", directory)
        ...     assert rv.returncode == 0
        ...     assert (directory / "README").exists()

    Args:
        owner: github owner, None to use GIT or USER environment variable if not defined (Default: `GIT`)
        repo: github repository (Default: `PROJECT`)
        scheme: url scheme (Default: "https")
        path: path to clone (Default: `repo`)

    Returns:
        CompletedProcess
    """
    path = path or Path.cwd() / repo
    path = Path(path)
    if not path.exists():
        if not path.parent.exists():
            path.parent.mkdir(parents=True)
        return cmd("git", "clone", github_url(owner, repo, scheme), path)
    return None


def cmdsudo(*args, user: str = "root", **kwargs) -> CompletedProcess | None:
    """
    Run Program with sudo if user is different that the current user

    Arguments:
        *args: command and args to run
        user: run as user (Default: False)
        **kwargs: subprocess.run kwargs

    Returns:
        CompletedProcess if the current user is not the same as user, None otherwise
    """
    if not ami(user):
        return cmd(["sudo", "-u", user, *args], **kwargs)
    return None


def dmg(src: Path | str, dest: Path | str) -> None:
    """
    Open dmg file and copy the app to dest

    Examples:
        # >>> await dmg(Path("/tmp/JetBrains.dmg"), Path("/tmp/JetBrains"))

    Args:
        src: dmg file
        dest: path to copy to

    Returns:
        CompletedProcess
    """
    with TempDir() as tmpdir:
        cmd("hdiutil", "attach", "-mountpoint", tmpdir, "-nobrowse", "-quiet", src)
        for item in src.iterdir():
            if item.name.endswith(".app"):
                cmd("cp", "-r", tmpdir / item.name, dest)
                cmd("xattr", "-r", "-d", "com.apple.quarantine", dest)
                cmd("hdiutil", "detach", tmpdir, "-force")
                break


def gz(src: Path | str, dest: Path | str = ".") -> Path:
    """
    Uncompress .gz src to dest (default: current directory)

    It will be uncompressed to the same directory name as src basename.
    Uncompressed directory will be under dest directory.

    Examples:
        >>> cwd = Path.cwd()
        >>> with TempDir() as workdir:
        ...     os.chdir(workdir)
        ...     with TempDir() as compress:
        ...         file = compress / "test.txt"
        ...         file.touch()  # doctest: +ELLIPSIS
        ...         compressed = tardir(compress)
        ...         with TempDir() as uncompress:
        ...             uncompressed = gz(compressed, uncompress)
        ...             assert uncompressed.is_dir()
        ...             assert Path(uncompressed).joinpath(file.name).exists()
        >>> os.chdir(cwd)

    Args:
        src: file to uncompress
        dest: destination directory to where uncompress directory will be created (default: current directory)

    Returns:
        Absolute Path of the Uncompressed Directory
    """
    dest = Path(dest)
    with tarfile.open(src, "r:gz") as tar:
        tar.extractall(dest)
        return (dest / tar.getmembers()[0].name).parent.absolute()


def is_terminal(self: rich.console.Console | None = None) -> bool:
    """
    Patch of :data:``rich.Console.is_terminal`` for PyCharm.

    Check if the console is writing to a terminal.

    Returns:
        bool: True if the console writing to a device capable of
        understanding terminal codes, otherwise False.
    """
    if not isinstance(self, rich.console.Console):
        self = c if (c := globals().get('console')) is not None and isinstance(c, rich.console.Console) \
            else rich.console.Console()

    if self._force_terminal is not None:
        return self._force_terminal

    try:
        return IS_REPL or (hasattr(self, "file") and hasattr(self.file, "isatty") and self.file.isatty())
    except ValueError:
        return False


def python_latest(start: str | int | None = None) -> VersionInfo:
    """
    Python latest version avaialble

    Examples:
        >>> v = platform.python_version()
        >>> assert python_latest(v).match(f">={v}")
        >>> assert python_latest(v.rpartition(".")[0]).match(f">={v}")
        >>> assert python_latest(sys.version_info.major).match(f">={v}")

    Args:
        start: version startswith match, i.e.: "3", "3.10", "3.10", 3 or None to use `PYTHON_VERSION`
          environment variable or :obj:``sys.version`` if not set (Default: None).

    Returns:
        Latest Python Version
    """
    start = str(start)
    start = start.rpartition(".")[0] if len(start.split(".")) == 3 else start
    return sorted([i for i in python_versions() if str(i).startswith(start)])[-1]


def python_version() -> str:
    """
    Major and Minor Python Version from :obj:`shrc.env.PYTHON_VERSION` environment variable or :obj:`sys.version`

    Examples:
        >>> v = python_version()
        >>> assert platform.python_version().startswith(v)
        >>> assert len(v.split(".")) == 2

    Returns:
        str
    """
    from .env import PYTHON_VERSION
    return PYTHON_VERSION or platform.python_version().rpartition(".")[0]


def python_versions() -> tuple[VersionInfo, ...]:
    """
    Python versions avaialble

    Examples:
        >>> v = platform.python_version()
        >>> assert v in python_versions()

    Returns:
        Tuple of Python Versions
    """
    return tuple(VersionInfo.parse(i.string)
                 for l in bs4.BeautifulSoup(requests.get(PYTHON_FTP).text, 'html.parser').find_all('a')
                 if (i := re.match(r'(([3]\.([7-9]|[1-9][0-9]))|[4]).*', l.get('href').rstrip('/'))))


def rinspect(obj: Any, *, _console: rich.console.Console | None = None, title: str | None = None,
             _help: bool = False, methods: bool = True, docs: bool = False, private: bool = True,
             dunder: bool = False, sort: bool = True, _all: bool = False, value: bool = True,) -> None:
    """
    :func:`rich.inspect` wrapper for :class:`rich._inspect.Inspect`,
    changing defaults to: ``docs=False, methods=True, private=True``.

    Inspect any Python object.

    * inspect(<OBJECT>) to see summarized info.
    * inspect(<OBJECT>, methods=True) to see methods.
    * inspect(<OBJECT>, help=True) to see full (non-abbreviated) help.
    * inspect(<OBJECT>, private=True) to see private attributes (single underscore).
    * inspect(<OBJECT>, dunder=True) to see attributes beginning with double underscore.
    * inspect(<OBJECT>, all=True) to see all attributes.

    Args:
        obj (Any): An object to inspect.
        _console (Console, optional): Rich Console.
        title (str, optional): Title to display over inspect result, or None use type. Defaults to None.
        _help (bool, optional): Show full help text rather than just first paragraph. Defaults to False.
        methods (bool, optional): Enable inspection of callables. Defaults to False.
        docs (bool, optional): Also render doc strings. Defaults to True.
        private (bool, optional): Show private attributes (beginning with underscore). Defaults to False.
        dunder (bool, optional): Show attributes starting with double underscore. Defaults to False.
        sort (bool, optional): Sort attributes alphabetically. Defaults to True.
        _all (bool, optional): Show all attributes. Defaults to False.
        value (bool, optional): Pretty print value. Defaults to True.
    """
    rich.inspect(obj=obj, console=_console, title=title, help=_help, methods=methods, docs=docs, private=private,
                 dunder=dunder, sort=sort, all=_all, value=value)


def syssudo(user: str = "root") -> CompletedProcess | None:
    """
    Rerun Program with sudo ``sys.executable`` and ``sys.argv`` if user is different that the current user

    Arguments:
        user: run as user (Default: False)

    Returns:
        CompletedProcess if the current user is not the same as user, None otherwise
    """
    if not ami(user):
        return cmd(["sudo", "-u", user, sys.executable, *sys.argv])
    return None


def tardir(src: Path | str) -> Path:
    """
    Compress directory src to <basename src>.tar.gz in cwd

    Examples:
        >>> cwd = Path.cwd()
        >>> with TempDir() as workdir:
        ...     os.chdir(workdir)
        ...     with TempDir() as compress:
        ...         file = compress / "test.txt"
        ...         file.touch()  # doctest: +ELLIPSIS
        ...         compressed = tardir(compress)
        ...         with TempDir() as uncompress:
        ...             uncompressed = gz(compressed, uncompress)
        ...             assert uncompressed.is_dir()
        ...             assert Path(uncompressed).joinpath(file.name).exists()
        >>> os.chdir(cwd)

    Args:
        src: directory to compress

    Raises:
        FileNotFoundError: No such file or directory
        ValueError: Can't compress current working directory

    Returns:
        Compressed Absolute File Path
    """
    src = Path(src)
    if not src.exists():
        raise FileNotFoundError(f"{src}: No such file or directory")

    if src.resolve() == Path.cwd().resolve():
        raise ValueError("Can't compress current working directory")

    name = Path(src).name + ".tar.gz"
    dest = Path(name)
    with tarfile.open(dest, 'w:gz') as tar:
        for root, _, files in os.walk(src):
            for file_name in files:
                tar.add(os.path.join(root, file_name))
        return dest.absolute()


def tilde(path: str | Path = '.') -> str:
    """
    Replaces $HOME with ~

    Examples:
        >>> assert tilde(f"{Path.home()}/file") == f"~/file"

    Arguments
        path: path to replace (default: '.')

    Returns:
        str
    """
    return str(path).replace(str(Path.home()), '~')


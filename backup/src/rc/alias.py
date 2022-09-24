# coding=utf-8
"""
Typings Module
"""
__all__ = (
    'ic',
    'icc',
)


try:
    from icecream import IceCreamDebugger  # type: ignore[name-defined]
    ic = IceCreamDebugger(prefix=str())
    icc = IceCreamDebugger(prefix=str(), includeContext=True)
except ModuleNotFoundError:
    ic = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa
    ics = lambda *a: None if not a else (a[0] if len(a) == 1 else a)  # noqa

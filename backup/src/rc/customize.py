# coding=utf-8
"""
Shrc Customize Module
Examples:

>>> import site  # doctest: +SKIP
>>> from pathlib import Path  # doctest: +SKIP
>>> (Path(site.__file__).parent / "sitecustomize.py").write_text("from shrc.customize import *")  # doctest: +SKIP
"""

# TODO: tests pendientes y comando actualizar el sitecustomize.py, ver ue tengo si solo importo shrc.startup en consola o si al final
#  es lo mismo que hacer una funcion y llamar en __init__.py asi no tengo que importar en startup.py todo lo de env...

import importlib.util
from . import typings
from importlib.util import spec_from_file_location
print(typings.__spec__.name)
# "shrc.customize" in sys.modules
print("__spec__" in globals())
type(importlib.util.find_spec('mierda'))
importlib.util.find_spec('shrc')
import sys
print('shrc' in sys.modules)

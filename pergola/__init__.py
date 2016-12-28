#  Copyright (c) 2014-2016, Centre for Genomic Regulation (CRG).
#  Copyright (c) 2014-2016, Jose Espinosa-Carrasco and the respective authors.
#
#  This file is part of Pergola.
#
#  Pergola is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Pergola is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Pergola.  If not, see <http://www.gnu.org/licenses/>.

"""
===========
Description
===========

Pergola is a set of python modules for transforming your data in data visualizable
in common genome browser

============
Installation
============

pergola requires:

* Python >=2.6
* numpy (http://numpy.scipy.org/)
* argparse (http://code.google.com/p/argparse/)
* csv (http://www.object-craft.com.au/projects/csv/)

Latest source code is available from GitHub::

https://github.com/cbcrg/pergola

by clicking on "Downloads", or by cloning the git repository with::

$ git clone https://github.com/cbcrg/pergola.git
    
=======
License
=======

Pergola is released under the GNU General Public License 3.0. A copy
of this license is in the LICENSE file.

"""

__version__ = '0.1'
__all__ = ['intervals', 'isatab_parser', 'mapping', 'parsers', 'tracks', 'jaaba_parsers']
# from pergola import printTest
# from intervals import IntData
# from pergola import intervals
# from tracks import DataIter

# def readme():
#     print "A library to visualize behavioral data in a genome browser"
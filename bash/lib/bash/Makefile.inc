#
# Sample makefile for bash loadable builtin development
#
# Copyright (C) 2015-2022 Free Software Foundation, Inc.     

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

PACKAGE = bash
VERSION = 5.2-release

PACKAGE_NAME = bash
PACKAGE_VERSION = 5.2-release

# Include some boilerplate Gnu makefile definitions.
prefix = /Users/j5pu/rc/bash

exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
libdir = ${exec_prefix}/lib
infodir = ${datarootdir}/info
includedir = ${prefix}/include

datarootdir = ${prefix}/share

loadablesdir = ${libdir}/bash
headersdir = $(includedir)/$(PACKAGE_NAME)

topdir = ../..
BUILD_DIR = /var/folders/py/0r7r_m4d71j6h0tkd274_sgm0000gn/T/tmp.phnwwrhL
srcdir = .


# Support an alternate destination root directory for package building
DESTDIR =

INSTALL = /usr/local/bin/ginstall -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_SCRIPT = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALLMODE= -m 0755


CC = gcc
RM = rm -f

SHELL = /bin/sh

host_os = darwin21.6.0
host_cpu = x86_64
host_vendor = apple

CFLAGS = -DARRAY_EXPORT='1'       -DCASEMOD_CAPCASE='1'       -DCASEMOD_TOGGLECASE='1'       -DCHECKWINSIZE_DEFAULT='1'       -DHISTEXPAND_DEFAULT='1'       -DHISTCONTROL='erasedups'
      -DMULTIPLE_COPROCS=1       -DNON_INTERACTIVE_LOGIN_SHELLS=1       -DOPTIMIZE_SEQUENTIAL_ARRAY_ASSIGNMENT=1       -DSSH_SOURCE_BASHRC=1       -DSYS_BASH_LOGOUT='"/Users/j5pu/rc/bash/etc/bash_logout"'       -DSYS_BASHRC='"/Users/j5pu/rc/bash/etc/bashrc"'       -DSYS_INPUTRC='"/Users/j5pu/rc/bash/etc/inputrc"'       -DSYS_PROFILE='"/Users/j5pu/rc/bash/etc/profile"'     
LOCAL_CFLAGS = -DMACOSX
DEFS = -DHAVE_CONFIG_H
LOCAL_DEFS = -DSHELL

CPPFLAGS = 

BASHINCDIR = ${topdir}/include

SUPPORT_SRC = $(topdir)/support/

LIBBUILD = ${BUILD_DIR}/lib

INTL_LIBSRC = ${topdir}/lib/intl
INTL_BUILDDIR = ${LIBBUILD}/intl
INTL_INC = -I${INTL_LIBSRC} -I${INTL_BUILDDIR}
LIBINTL_H = ${INTL_BUILDDIR}/libintl.h

CCFLAGS = $(DEFS) $(LOCAL_DEFS) $(LOCAL_CFLAGS) $(CFLAGS)

#
# These values are generated for configure by ${topdir}/support/shobj-conf.
# If your system is not supported by that script, but includes facilities for
# dynamic loading of shared objects, please update the script and send the
# changes to bash-maintainers@gnu.org.
#
SHOBJ_CC = gcc
SHOBJ_CFLAGS = -fno-common
SHOBJ_LD = ${CC}
SHOBJ_LDFLAGS = -dynamiclib -dynamic -undefined dynamic_lookup  
SHOBJ_XLDFLAGS = 
SHOBJ_LIBS = 
SHOBJ_STATUS = supported

INC = -I$(headersdir) -I$(headersdir)/include -I$(headersdir)/builtins

.c.o:
	$(SHOBJ_CC) $(SHOBJ_CFLAGS) $(CCFLAGS) $(INC) -c -o $@ $<

#! /bin/sh
# Copyright (C) 2009-2012 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# If $(javadir) is the empty string, then nothing should be installed there.

required=javac
. ./defs || Exit 1

cat >>configure.ac <<'END'
AC_OUTPUT
END

cat >Makefile.am <<'END'
javadir = $(datarootdir)/java
java_JAVA = foo.java
END

cat >foo.java <<'END'
class foo {
}
END

$ACLOCAL
$AUTOCONF
$AUTOMAKE --add-missing

cwd=$(pwd) || fatal_ "getting current working directory"
instdir=$cwd/inst
destdir=$cwd/dest
mkdir build
cd build
../configure --prefix="$instdir"
$MAKE

javadir=
export javadir
$MAKE -e install
test ! -d "$instdir"
$MAKE -e install DESTDIR="$destdir"
test ! -d "$instdir"
test ! -d "$destdir"
$MAKE -e uninstall > stdout || { cat stdout; Exit 1; }
cat stdout
grep 'rm -f' stdout && Exit 1
$MAKE -e uninstall DESTDIR="$destdir"

:
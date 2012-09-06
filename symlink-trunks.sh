#!/bin/sh
#
# Copyright (C) 1995, 2000, 2003  Free Software Foundation, Inc.
# Copyright (C) 2009 Embecosm Limited
#
# Contributor Joern Rennecke <joern.rennecke@embecosm.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.

# Synatx:
# symlink-trunks "srcdir1 srcdir2 ..." [options] "ignore1 ignore2 ..."
# where srcdirN is a directory to create a symlink to
# for each file/directory contained,
# and "ignoreN" is a list of files/directories to ignore.
# options:
# --remove-old: remove any old files / directories that are in the way
# --dest <dir>: specify new directory to create.
# symlink-trunks "srcdir1 srcdir2 ..." [--remove-old] "ignore1 ignore2 ..."

prog=$0
remove_old=""
dest=""
# parse options
until
  opt=$1
  case ${opt} in
    --remove-old)
      remove_old=yes ;;
    --dest)
      dest=$2; shift ;;
    *)
      opt="";;
   esac;
  [ -z "${opt}" ]; do 
    shift
  done
srcdirs="$1"
ignore="$2"

if test $# -lt 1; then
  echo "symlink-trunks error:  Usage: symlink-trunks [options] \"srcdir1 srcdir2 ...\" \"ignore1 ignore2 ...\""
  echo options:
  echo --remove-old: remove any old files / directories that are in the way
  echo --dest <dir>: specify new directory to create.
  exit 1
fi

ignore_additional=". .. CVS .cvsignore .svn .git .gitignore"

case ${dest} in
  "") prefix='.';;
  */*) echo "/ in <dest> not implemented"; exit 1;;
  *..*) echo ".. in <dest> not implemented"; exit 1;;
  *) prefix='..' ;;
esac

if [ -n "${dest}" ]; then
  if [ ! -d ${dest} ]; then
    if [ -e ${dest} ]; then
      if [ "${remove_old}" == yes ]; then
	rm -f ${dest}
      else
	echo "${dest} is not a directory"; exit 1
      fi
    fi
    mkdir ${dest}
  fi
  cd ${dest}
fi

for srcdir in ${srcdirs}; do
  case ${srcdir} in
    /* | [A-Za-z]:[\\/]*) ;;
    *) srcdir="${prefix}/${srcdir}" ;;
  esac
  files=`ls -a ${srcdir}`
  for f in ${files}; do
    found=
    for i in ${ignore} ${ignore_additional}; do
      if [ "x$f" = "x$i" ]; then
	found=yes
      fi
    done
    if [ -z "${found}" ]; then
      echo "$f		..linked"
      if [ "x${remove_old}" = "xyes" ]; then
	rm -f $f
      fi
      ln -s ${srcdir}/$f .
    fi
  done
  ignore_additional="${ignore_additional} ${files}"
done

exit 0

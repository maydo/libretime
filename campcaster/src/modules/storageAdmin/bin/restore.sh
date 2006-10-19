#!/bin/bash
#-------------------------------------------------------------------------------
#   Copyright (c) 2004 Media Development Loan Fund
#
#   This file is part of the Campcaster project.
#   http://campcaster.campware.org/
#   To report bugs, send an e-mail to bugs@campware.org
#
#   Campcaster is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   Campcaster is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Campcaster; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Author   : $Author$
#   Version  : $Revision$
#   Location : $URL$
#-------------------------------------------------------------------------------                                                                                
#-------------------------------------------------------------------------------
#  This script restores LS data previously backuped by backup.sh
#
#  To get usage help, try the -h option
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  Determine directories, files
#-------------------------------------------------------------------------------

reldir=`dirname $0`/..
phpdir=ls_storageAdmin_phppart_dir
if [ "$phpdir" == "ls_storageAdmin_phppart_dir" ]
then
    phpdir=`cd $reldir/var; pwd`
fi
mkdir -p $reldir/tmp
tmpmaindir=`cd $reldir/tmp; pwd`
dbxml="db.xml"
tarfile0="xmls.tar"

#-------------------------------------------------------------------------------
#  Print the usage information for this script.
#-------------------------------------------------------------------------------
printUsage()
{
    echo "This script restores LS data previously backuped by backup.sh.";
    echo "parameters:";
    echo "";
    echo "  -f, --file          File with backuped data, required.";
    echo "  -h, --help          Print this message and exit.";
    echo "";
}

#-------------------------------------------------------------------------------
#  Process command line parameters
#-------------------------------------------------------------------------------
CMD=${0##*/}

opts=$(getopt -o hf: -l help,file -n $CMD -- "$@") || exit 1
eval set -- "$opts"
while true; do
    case "$1" in
        -h|--help)
            printUsage;
            exit 0;;
        -f|--file)
            tarfile=$2
            shift; shift;;
        --)
            shift;
            break;;
        *)
            echo "Unrecognized option $1.";
            printUsage;
            exit 1;
    esac
done

if [ "x$tarfile" == "x" ]; then
    echo "Required parameter file not specified.";
    printUsage;
    exit 1;
fi

tfdir=`dirname $tarfile`
tfdir=`cd $tfdir; pwd`
tfbname=`basename $tarfile`
tarfile="$tfdir/$tfbname"

#-------------------------------------------------------------------------------
#   Do restore
#-------------------------------------------------------------------------------

tmpdir=`mktemp -d $tmpmaindir/tmp.XXXXXX`

echo "Restoring database from $tarfile ..."
cd $tmpdir
tar xf $tarfile
tar xjf $tarfile0.bz2
rm -f $tarfile0.bz2
cd $phpdir
php -q restore.php $tmpdir/$dbxml $tmpdir
rm -rf "$tmpdir/stor"
rm -f $tmpdir/*
rmdir "$tmpdir"


#-------------------------------------------------------------------------------
#   Say goodbye
#-------------------------------------------------------------------------------
echo "done"

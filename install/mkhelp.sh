#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report (c) 2003-2004 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# This script creates the help files based on your configuration file. You need
# to run it for the first time installation and whenever certain variables in
# your configuration change (see "Uses:" below)
# -----------------------------------------------------------------------------
# Uses: CSS
# =============================================================================

. ../config

HCSS=`echo $CSS|sed 's/\.\./\\\.\\\./g'|sed 's/\//\\\\\//g'`
SEDC="s/{css}/$HCSS/g"
for i in *.tpl; do
  TARGET=$REPDIR/help/${i%%.*}.html
  sed $SEDC $i >$TARGET
  chmod o+r $TARGET
done
cp help.gif $REPDIR/help/
chmod o+r help.gif

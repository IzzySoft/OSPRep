# =============================================================================
# Oracle StatsPack Report 2 HTML       (c) 2003 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# $Id$
# -----------------------------------------------------------------------------
# Create an Oracle StatsPack Report in HTML format
# =============================================================================

Contents
--------

1) Copyright and warranty
2) Requirements
3) Limitations
4) Installation
5) Plugins

===============================================================================

1) Copyright and Warranty
-------------------------

This little program is (c)opyrighted by Andreas Itzchak Rehberg
(devel@izzysoft.de) and protected by the GNU Public License Version 2 (GPL).
For details on the License see the file LICENSE in this directory. The
contents of this archive may only be distributed all together.

===============================================================================

2) Requirements
---------------

Since this is a report generator for the Oracle StatsPack utility, it implies
two requirements: Oracle and the StatsPack installed. In order to be able to
generate a report, you must have collected some snapshot data (for details on
this, see the StatsPack documentation).
Additionally, you must have a shell available - what implies that you run a
*NIX operating system. Tested on RedHat Linux with the bash shell v2.

===============================================================================

3) Limitations
--------------

I tested the script only with Oracle v9.0.1 and v9.2 and thus cannot promise
it will run with any other version. If you want to use it with another version,
you must know the specification for the statspack.stat_changes procedure (see
the files sp90.pls and sp92.pls). The script automatically tries to find out
your database version and then uses the appropriate script. Therefore it just
connects the first two parts of the DB version number: so v9.0.1 leads to
sp90.pls being used, an Oracle 8.1.7 would lead to sp81.pls - you may try to
experiment with copying the provided files. A better idea is to see the
?/rdbms/admin/spreport.sql file for the exact specification and creating your
sp??.pls file yourself. Although, no warranty that this will work.

One more limitation to mention: the information in this reports is equivalent
to what spreport.sql would give you on level 5 snapshots. So if you need the
additional data for higher levels reported, OSPRep won't help you.

===============================================================================

4) Installation
---------------

Just copy all files from the root directory of this archive to a suitable
place and adjust the file "config" to reflect your settings. That file is the
only one you need to edit, leave the others untouched.
To run the script, start spreport.sh - calling it with no parameters tells
you its syntax. It will run with just giving it the ORACLE_SID of the database
to report on as only parameter - provided, your Oracle environment is set up
correctly. For the two optional parameters, see the config file on START_ID and
END_ID.

===============================================================================

5) Plugins
---------------

With v0.1.2 I started to include 1 plugin (if there are more of them, this
readme.txt has not been updated since ;) Read more on them in the files
contained in the plugins/ directory.
For the gathering of the wait objects statistics, you need to create the
table in the perfstat users schema (you may use the waitobj.sql file to do
this), plus the procedure to gather the information. The latter must be
installed in the SYS schema - no other schema will work. Please, don't blame
me, it's not my fault - it's due to some strange behaviour in PL/SQL when
accessing certain v$ views. It seems that Oracle does know about, so they didn't
already include this little addon...
When you used getwaits.sql to create the procedure, the perfstat user is able
to run it (if your perfstat schema is not named "perfstat", you may need to
edit the file first: look at the line starting with "GRANT"). So if you do
your snapshots for the statspack, do not forget to run this procedure with it.


Have fun!
Izzy.

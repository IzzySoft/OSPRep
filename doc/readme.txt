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

The same "auto-detection" mode applies to snap level 6 data as well as to
possible future plugins: I will try to always keep the report script
compatible with the "defaults" but automatically get the best out of your
database for you when detecting features.

Moreover you should remember: when only taking snapshots at level 5, OSPRep
cannot report level 6 data (such as e.g. execution plans). But I would not
regard this a limitation of OSPRep but rather of your data collection in this
case :-)

===============================================================================

4) Installation
---------------

1. Create the directory where the report files (*.html) should be placed in.
   As example, we assume the /var/www/html/oracle/reports directory here.
2. Below this directory, create another directory named "help". Make sure
   both directories have the right permissions so your webserver can read all
   contained files.
3. Create a directory to hold the scripts - this should *NOT* be below your
   web servers document root. As example, we use ~/scripts here.
4. Unpack this archive (including sub directories) to ~/scripts
   (since you read this file, you may already have the archive unpacked; in
   this case just move the files there).
5. Edit the ~/scripts/config file to reflect your settings. That file is the
   only one you need to edit, leave the others untouched. Important to change
   are at least the settings for user, password, REPDIR (if other than in our
   example) and the location of the style sheet (which you need to copy there)
6. Go to the ~scripts/install directory and execute mkhelp.sh which creates
   the help files (placement of the stylesheet is adjusted this way) in the
   /var/www/html/oracle/reports/help directory, copies the help icon to this
   location and sets the file permissions so everybody can read them.
7. In six days G*d created the heavens and the earth - the seventh is Shabbat,
   and He rested. Get yourself a cup of coffee, tea or whatever you like, and
   relax for a moment.

To run the script, start spreport.sh - calling it with no parameters tells
you its syntax. It will run with just giving it the ORACLE_SID of the database
to report on as only parameter - provided, your Oracle environment is set up
correctly. For the two optional parameters, see the config file on START_ID and
END_ID.

===============================================================================

5) Plugins
----------

With v0.1.2 I started to include 1 plugin (if there are more of them and NOT
mentioned in this block, this readme.txt has not been updated since ;) Read
more on them in the files contained in the plugins/ directory.

For the gathering of the wait objects statistics, you need to create the
table in the perfstat users schema (you may use the waitobj.sql file to do
this), plus the procedure (getwaits.sql) to gather the information. When doing
your snapshots for the statspack, do not forget to run this procedure with it.

The very same applies to the datafiles growth statistics - a new plugin
introduced with v0.1.5: use the fileobj.sql file to create the data structs,
plus getfilestat.sql for the collector procedure.

A different "PlugIn" is the script fts_plans.sh in the root directory of this
bundle. It obeys the same syntax as the main (sreport.sh) script, but does a
different job: it collects the statements and execution plans for all queries
that caused full table scans (FTS). These are most likely to require some
optimization - usually creation of new indices or rewrite of the queries (e.g.
placing index hints). The output is written into the file <ORACLE_SID>_fts.html
in the report directory.


Have fun!
Izzy.

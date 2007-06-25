# =============================================================================
# Oracle StatsPack Report 2 HTML  (c) 2003-2005 by IzzySoft (devel@izzysoft.de)
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
5) Extensions
6) AddOns
7) Additional information

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

4a) StatsPack & Extensions
°°°°°°°°°°°°°°°°°°°°°°°°°°

If you did not yet install StatsPack into your database, this is logically
the first step. Usually, it simply requires you to connect as sysdba and call
@?/rdbms/admin/spcreate.sql - which asks you a few questions and does all the
work. To make it easier for you to install the OSPRep extensions along plus,
as a side-effect, have a script ready for unattended installation on multiple
(similiar configured) instances, spcreate.sh was added to the distribution.

You will find this script within the install/ directory (below the directory
where you unpacked the archive). It will install Oracle StatsPack, the OSPRep
extensions, and create a job to run every hour at the hour (like it is done
by ?/rdbms/admin/spauto.sql - but also catering the extensions).

1. Open it with your favorite editor, and adjust the settings in the
   configuration section to reflect your systems configuration.
2. Save your changes
3. Run the script
4. Have a cup of coffee or a glas of tea - but the script will be finished
   earlier than your drink :-)

To verify whether it ran successfully, you may check the logfiles it created
(one is created by spcreate.sh, and some more by the called Oracle scripts).

4b) OSPRep itself
°°°°°°°°°°°°°°°°°

1. Create the directory where the report files (*.html) should be placed in.
   As example, we assume the /var/www/html/oracle/reports directory here.
2. Below this directory, create two other directories named "help" and "inc".
   Make sure the directories have the right permissions so your webserver can
   read all contained files.
3. Create a directory to hold the scripts - this should *NOT* be below your
   web servers document root. As example, we use ~/scripts here.
4. Unpack this archive (including the plugins/ and install/ sub directories)
   to ~/scripts (since you read this file, you may already have the archive
   unpacked; in this case just move the files there).
5. Edit the ~/scripts/config file to reflect your settings. That file is the
   only one you need to edit, leave the others untouched. Important to change
   are at least the settings for user, password, REPDIR (if other than in our
   example) and the location of the style sheet (which you need to copy there;
   just select one of the *.css files provided in the reports/ directory)
6. Go to the ~scripts/install directory and execute mkhelp.sh which creates
   the help files (placement of the stylesheet is adjusted this way) in the
   /var/www/html/oracle/reports/help directory, copies the help icon to this
   location and the chart includes to the /var/www/html/oracle/reports/inc
   directory plus sets the file permissions so everybody can read them.
7. In six days G*d created the heavens and the earth - the seventh is Shabbat,
   and He rested. Get yourself a cup of coffee, tea or whatever you like
   (oh yeah - not yet finished the first one?), and relax for a moment.

To run the script, start spreport.sh - calling it with no parameters tells
you its syntax. It will run with just giving it the ORACLE_SID of the database
to report on as only parameter - provided, your Oracle environment is set up
correctly. For the optional parameters -b (BEGIN_SNAP_ID) and -e (END_SNAP_ID),
see the config file on START_ID and END_ID.

4c) AddOns
°°°°°°°°°°

Starting with v0.4.x, the AddOns are already converted from "anonymous blocks"
to "stored procedures" - which means, in order to use them, you need to install
the osprep package into the database. If you did not install them with the
spcreate.sh described above, this can be done manually as follows:

1. Change to the install/database/ subdirectory of your OSPRep installation
2. Invoke Sql*Plus and connect as the statspack user (perfstat)
3. Run the following command:
   @pkg_osprep.sql

That's all - you are done. Read more about the AddOns in the corresponding
section of this document (or the HTML documentation).

===============================================================================

5) Extensions
-------------

There are some extensions shipped with OSPRep, which may be installed
automatically with the spcreate.sh as described in the Installation section
of this document. These are, at the time of writing these lines:

- File Statistics       : Watch datafile growth
- Session Statistics    : Work around some session stats bug in Oracle
- Wait Statistics       : Wait Object statistics

If you did not use the spcreate.sh for the automatic installation (e.g. since
you had already setup Oracle StatsPack before), you may need to install the
required objects manually - of course only for the extensions you want to use.
For the extensions where there are multiple files required to install, the
order of installation *IS* important:

- File Statistics       : install/database/fileobj.sql and install/getfilestat.sql
- Session Statistics    : install/database/get_sesstat.sql
- Wait Statistics       : install/database/waitobj.sql and install/getwaits.sql

When doing your snapshots for the statspack, do not forget to run the
appropriate procedures immediately after that (again, the spcreate.sh will set
this up for you accordingly). These are:

- File Statistics       : get_fileinfo
- Session Statistics    : get_sesstat
- Wait Statistics       : get_waitevents

The session statistics plugin introduced with v0.3.5 gathers the (summarized)
session stats into the stats$sesstat table (normally used by StatsPack itself
when run in level 10 -- so make sure to not combine them). The main reason for
this is to work around some statistic bugs with v$sysstat in Oracle up to
10.1.0.4 (see e.g. MetaLink note 3926058.8), so we can find the correct values
from these (summarized) session stats. Currently, it is only used for the open
cursor statistics, so you will need this only if you are affected by the
mentioned bug but need accurat open cursor stats.

===============================================================================

6) AddOns
---------

There are some more scripts included in this distribution - let's call them
AddOns. What they have in common is that they create some HTML as well:

One script is fts_plans.sh in the root directory of this bundle. It obeys the
same syntax as the main (sreport.sh) script, but does a different job: it
collects the statements and execution plans for all queries that caused full
table scans (FTS). These are most likely to require some optimization -
usually creation of new indices or rewrite of the queries (e.g. placing index
hints). The output is written into the file <ORACLE_SID>_fts.html in the
report directory.

To visualize the gathered report data, you may want to use the charts.sh script
(same syntax again). It just generates data files for the JavaScript chart
generator, plus a controlling HTML file called <ORACLE_SID>_chart.html in the
REPDIR directory.

===============================================================================

7) Additional information
-------------------------

Additonal and more verbose information is available in HTML format. You will
find this documentation in the subdirectory doc/html as part of the distribution.
The latest version (of the program as well as of the documentation) can be
found at http://www.izzysoft.de/?topic=oracle


Have fun!
Izzy.

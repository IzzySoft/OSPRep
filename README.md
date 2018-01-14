**Note:** *OSPRep* is no longer maintained.

### What is OSPRep?
*OSPRep* is an Oracle Statspack Report Generator, used to create reports about
your database activity statistics in a nice, human readable format –
which in this case is HTML –, based on the data collected by Oracle
Statspack (or alternatively, using the compatibility layer, on the AWR
collected data) and, optionally, some plugins shipped with OSPRep. The
generated report provides you with information on the physical database
design (tablespaces, datafiles, memory), statistical values on your databases
efficiency and more. It is highly configurable not only concerning the report
elements you need. Due to its modular design, only the needed code (depending
on the options you chose in the config file) will be build and executed, to
save your database from unnecessary load.


### What does OSPRep do?
*OSPRep* reads its data out of the (level 5 - 7) statistics gathered by the
`statspack.snap()` procedure of Oracle Statspack and the corresponding
procedures from above mentioned plugins. Analogue to the ASCII report one may
generate using Oracle Statspack's `spreport.sql`, *OSPrep* generates HTML
reports out of these data. The additional information gathered (and reported)
by the mentioned plugins includes e.g. datafile growth and wait events.

Together with these data, *OSPRep* gives some descriptions on their meaning as
well as ideas what they may point to or what actions are required from the DBA
in order to bring the instance to a more efficient state. For some issues,
even code pieces for possible required actions are given.

Other useful things to mention here are the `fts_plans.sh` script provided by
OSPrep, which can be used to gather execution plans for all SQL statements
executed during a certain period of time, having caused full table scans (FTS;
this does not work against AWR data currently) – and the `charts.sh` script,
generating some simple charts for selected statistics. This way *OSPRep* gives
you the information on your finger tips to start the tuning of your
applications.


### What does OSPRep *NOT* do?
*OSPRep* will take no (write) actions to the database (only things that
*OSPRep* writes are the HTML report pages and some temporary files; the latter
ones are automatically removed when the script finishes). It only does report
what it finds in the database plus some general description on those values. It
gives no "perfect solution" to problems that may exist with your instance, just
hints to what may be helpful. It will not repair or tune your database for you:
in order to have this done, you must draw your own conclusions out of the report
results.

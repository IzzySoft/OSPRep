-- ===========================================================================
-- Oracle StatsPack Report      (c) 2003-2011 by IzzySoft  (devel@izzysoft.de)
-- ---------------------------------------------------------------------------
-- Compatibility Layer for AWR (Oracle 10g)
-- If you use Oracle 10g and don't want to install StatsPack, this provides a
-- compatibility layer to run the report on the AWR data present with 10g+
-- !!! ATTENTION: ACCESSING THE AWR DATA MEANS YOU HAVE TO LICENSE
-- !!! ENTERPRISE EDITION PLUS THE DIAGNOSTICS PACK!
-- Still interested? Then you need to create a database user with the same
-- permissions as required by StatsPacks PERFSTAT user. Do not install any
-- StatsPack stuff in there, instead connect with that user and run this script.
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- AWR support is far from being complete. There are still several open issues:
-- * Top-N-SQL Statements don't work. Here the table structure in AWR is
--   that much different from StatsPack, I couldn't yet figure out how to
--   create the layer (see below, look out for stats$sql_plan_usage).
--   It won't crash if enabled, but you will get no data for now.
-- If you have any ideas concerning these points, you are very welcome!
-- ---------------------------------------------------------------------------

SET ECHO OFF FEEDBACK OFF TRIMSPOOL OFF

WHENEVER SQLERROR EXIT

PROMPT ===========================================================
PROMPT Creating views to simulate StatsPack tables
PROMPT ===========================================================
PROMPT - Common Tables
PROMPT ... stats$resource_limit
CREATE OR REPLACE VIEW stats$resource_limit AS
  SELECT r.resource_name, r.current_utilization, r.max_utilization, r.initial_allocation,
         r.limit_value, r.snap_id, r.dbid, (SELECT instance_number FROM v$instance) instance_number
    FROM dba_hist_resource_limit r;

PROMPT ... stats$snapshot
CREATE OR REPLACE VIEW stats$snapshot AS
  SELECT s.snap_id, s.dbid, (SELECT instance_number FROM v$instance) instance_number,
         TO_DATE( TO_CHAR(end_interval_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' ) snap_time,
         TO_DATE( TO_CHAR(startup_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' ) startup_time,
         NULL session_id, NULL serial#, s.snap_level, NULL ucomment, NULL executions_th, NULL parse_calls_th,
         NULL disk_reads_th, NULL buffer_gets_th, NULL sharable_mem_th, NULL version_count_th,
         NULL seg_phy_reads_th, NULL seg_log_reads_th, NULL seg_buff_busy_th, NULL seg_rowlock_w_th,
         NULL seg_itl_waits_th, NULL seg_cr_bks_rc_th, NULL seg_cu_bks_rc_th, NULL seg_cr_bks_sd_th,
         NULL seg_cu_bks_sd_th, (
             TO_DATE( TO_CHAR(end_interval_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' )
           - TO_DATE( TO_CHAR(begin_interval_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' )
         ) * 8600 snapshot_exec_time_s,
         NULL all_init, NULL baseline
    FROM dba_hist_snapshot s;

PROMPT ... stats$database_instance
-- same info for all snap_ids, as there is no d.snap_id column; what can we do?
CREATE OR REPLACE VIEW stats$database_instance AS
  SELECT d.dbid, d.instance_number,
         TO_DATE( TO_CHAR(d.startup_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' ) startup_time,
         s.snap_id, d.parallel, d.version, d.db_name, d.instance_name, d.host_name
    FROM dba_hist_database_instance d, dba_hist_snapshot s
   WHERE d.startup_time = s.startup_time;

PROMPT ... stats$parameter
CREATE OR REPLACE VIEW stats$parameter AS
  SELECT p.snap_id, p.dbid, p.instance_number, p.parameter_name name, p.value, p.isdefault, p.ismodified
    FROM dba_hist_parameter p;

PROMPT ... stats$librarycache
CREATE OR REPLACE VIEW stats$librarycache AS
  SELECT l.snap_id, l.dbid, l.instance_number, l.namespace, l.gets, l.gethits, l.pins, l.pinhits,
         l.reloads, l.invalidations, l.dlm_lock_requests, l.dlm_pin_requests, l.dlm_pin_releases,
         l.dlm_invalidation_requests, l.dlm_invalidations
    FROM dba_hist_librarycache l;

PROMPT ... stats$sysstat
CREATE OR REPLACE VIEW stats$sysstat AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.stat_id statistic#, s.stat_name name, s.value
    FROM dba_hist_sysstat s;

PROMPT ... stats$waitstat
CREATE OR REPLACE VIEW stats$waitstat AS
  SELECT w.snap_id, w.dbid, w.instance_number, w.class, w.wait_count, w.time
    FROM dba_hist_waitstat w;

PROMPT ... stats$pgastat
CREATE OR REPLACE VIEW stats$pgastat AS
  SELECT p.snap_id, p.dbid, p.instance_number, p.name, p.value
    FROM dba_hist_pgastat p;

PROMPT ... stats$sga
CREATE OR REPLACE VIEW stats$sga AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.name, s.value,
         TO_DATE( TO_CHAR(i.startup_time,'YYYY-MON-DD HH24:MI:SS'),'YYYY-MON-DD HH24:MI:SS' ) startup_time,
         i.parallel, i.version
    FROM dba_hist_sga s, dba_hist_database_instance i
   WHERE s.dbid = i.dbid
     AND s.instance_number = i.instance_number
     AND i.startup_time = (SELECT startup_time FROM dba_hist_snapshot x  WHERE x.snap_id=s.snap_id);

PROMPT ... stats$sys_time_model
CREATE OR REPLACE VIEW stats$sys_time_model AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.stat_id, s.value
    FROM dba_hist_sys_time_model s;

PROMPT ... stats$osstat
CREATE OR REPLACE VIEW stats$osstat AS
  SELECT o.snap_id, o.dbid, o.instance_number, o.stat_id osstat_id, o.value
    FROM dba_hist_osstat o;

PROMPT ... stats$time_model_statname
CREATE OR REPLACE VIEW stats$time_model_statname AS
  SELECT DISTINCT s.stat_id, s.stat_name
    FROM dba_hist_sys_time_model s;

PROMPT ... stats$system_event
CREATE OR REPLACE VIEW stats$system_event AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.event_name event, s.total_waits, s.total_timeouts,
         s.time_waited_micro, s.event_id
    FROM dba_hist_system_event s;

PROMPT ... stats$latch
CREATE OR REPLACE VIEW stats$latch AS
  SELECT l.snap_id, l.dbid, l.instance_number, l.latch_name name, l.latch_hash latch#, l.level#,
         l.gets, l.misses, l.sleeps, l.immediate_gets, l.immediate_misses, l.spin_gets,
         l.sleep1, l.sleep2, l.sleep3, l.sleep4, l.wait_time
    FROM dba_hist_latch l;

PROMPT ... stats$idle_event
CREATE OR REPLACE VIEW stats$idle_event AS
  SELECT event
    FROM v$system_event
   WHERE wait_class='Idle';

PROMPT ... stats$sgastat
CREATE OR REPLACE VIEW stats$sgastat AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.name, s.pool, s.bytes
    FROM dba_hist_sgastat s;

PROMPT ... stats$osstatname
CREATE OR REPLACE VIEW stats$osstatname AS
  SELECT DISTINCT o.stat_id osstat_id, o.stat_name
    FROM dba_hist_osstat o;

PROMPT ... stats$sesstat (dummy again - could not find corresponding table/view)
CREATE OR REPLACE VIEW stats$sesstat AS
  SELECT NULL snap_id, NULL dbid, NULL instance_number, NULL statistic#, NULL value
    FROM DUAL;

PROMPT ... stats$dlm_misc
CREATE OR REPLACE VIEW stats$dlm_misc AS
  SELECT d.snap_id, d.dbid, d.instance_number, d.statistic#, d.name, d.value
    FROM dba_hist_dlm_misc d;

PROMPT ... stats$cr_block_server
CREATE OR REPLACE VIEW stats$cr_block_server AS
  SELECT b.snap_id, b.dbid, b.instance_number, b.cr_requests, b.current_requests,
         b.data_requests, b.undo_requests, b.tx_requests, b.current_results,
         b.private_results, b.zero_results, b.disk_read_results, b.fail_results,
         b.fairness_down_converts, b.fairness_clears, b.free_gc_elements, b.flushes,
         b.flushes_queued, b.flush_queue_full, b.flush_max_time, b.light_works, b.errors
    FROM dba_hist_cr_block_server b;

PROMPT ... stats$current_block_server
CREATE OR REPLACE VIEW stats$current_block_server AS
  SELECT b.snap_id, b.dbid, b.instance_number, b.pin1, b.pin10, b.pin100, b.pin1000, b.pin10000,
         b.flush1, b.flush10, b.flush100, b.flush1000, b.flush10000,
         b.write1, b.write10, b.write100, b.write1000, b.write10000
    FROM dba_hist_current_block_server b;

-- for top-N-SQL. As there's no [old_]hash_value for the statements anymore, we subst the sql_id for it
-- ATTENTION: No "pieces" here, complete statement is stored in sql_text (CLOB)!!!
PROMPT - Top-N-SQL
PROMPT ... stats$sqltext
CREATE OR REPLACE VIEW stats$sqltext AS
  SELECT t.sql_id old_hash_value, NULL text_subset, 1 piece, t.sql_id, t.sql_text, NULL address,
         t.command_type, t.snap_id last_snap_id
    FROM sys.wrh$_sqltext t;

PROMPT ... stats$sql_plan
CREATE OR REPLACE VIEW stats$sql_plan AS
  SELECT p.plan_hash_value, p.id, p.operation, p.options, p.object_node, p.object#, p.object_owner,
         p.object_name, p.object_alias, p.object_type, p.optimizer, p.parent_id, p.depth, p.position,
         p.search_columns, p.cost, p.cardinality, p.bytes, p.other_tag,
         p.partition_start, p.partition_stop, p.partition_id, p.other, p.distribution,
         p.cpu_cost, p.io_cost, p.temp_space, p.access_predicates, p.filter_predicates,
         p.projection, p.time, p.qblock_name, p.remarks, p.snap_id
    FROM sys.wrh$_sql_plan p;

-- For now just a dummy
PROMPT ... stats$sql_plan_usage (dummy)
--CREATE OR REPLACE VIEW stats$sql_plan_usage AS
--  SELECT ?.snap_id, ?.dbid, ?.instance_number, pt.sql_id old_hash_value, NULL text_subset,
--         pt.plan_hash_value, pt.sql_id hash_value, pt.sql_id, ?.cost, ?.address, ?.optimizer,
--         pt.last_load_time last_active_time
--    FROM sys.wri$_sqlset_plans_tocap pt;
CREATE OR REPLACE VIEW stats$sql_plan_usage AS
  SELECT NULL snap_id, NULL dbid, NULL instance_number, NULL old_hash_value, NULL text_subset,
         NULL plan_hash_value, NULL hash_value, NULL sql_id, NULL cost, NULL address,
         NULL optimizer, NULL last_active_time
    FROM DUAL
   WHERE 0=1;

-- Again a dummy -- until something suitable can be found
PROMPT ... stats$sql_summary (dummy)
--CREATE OR REPLACE VIEW stats$sql_summary AS
--  SELECT s.snap_id, s.dbid, s.instance_number
--    FROM dba_hist_sql_summary s;
CREATE OR REPLACE VIEW stats$sql_summary AS
  SELECT NULL snap_id, NULL dbid, NULL instance_number, NULL text_subset, NULL sql_text, NULL sql_id,
         NULL sharable_mem, NULL sorts, NULL module, NULL loaded_versions, NULL fetches,
         NULL executions, NULL px_server_executions, NULL end_of_fetch_count, NULL loads,
         NULL invalidations, NULL parse_calls, NULL disk_reads, NULL direct_writes, NULL buffer_gets,
         NULL application_wait_time, NULL concurrency_wait_time, NULL cluster_wait_time,
         NULL user_io_wait_time, NULL plsql_exec_time, NULL java_exec_time, NULL rows_processed,
         NULL command_type, NULL address, NULL hash_value, NULL old_hash_value, NULL version_count,
         NULL cpu_time, NULL elapsed_time, NULL outline_sid, NULL outline_category,
         NULL child_latch, NULL sql_profile, NULL program_id, NULL program_line#,
         NULL exact_matching_signature, NULL force__matching_signature, NULL last_active_time
    FROM DUAL
   WHERE 0=1;

-- TSIO and FIO: TableSpace and File Stats
PROMPT - TableSpace and File Stats
PROMPT ... stats$filestatxs
CREATE OR REPLACE VIEW stats$filestatxs AS
  SELECT f.snap_id, f.dbid, f.instance_number, f.tsname, f.filename, f.phyrds, f.phywrts,
         f.singleblkrds, f.readtim, f.writetim, f.singleblkrdtim, f.phyblkrd, f.phyblkwrt,
         f.wait_count, f.time, f.file#
    FROM dba_hist_filestatxs f;

PROMPT ... stats$tempstatxs
CREATE OR REPLACE VIEW stats$tempstatxs AS
  SELECT f.snap_id, f.dbid, f.instance_number, f.tsname, f.filename, f.phyrds, f.phywrts,
         f.singleblkrds, f.readtim, f.writetim, f.singleblkrdtim, f.phyblkrd, f.phyblkwrt,
         f.wait_count, f.time, f.file#
    FROM dba_hist_tempstatxs f;

-- Segment Statistics
PROMPT - Segment Statistics
PROMPT ... stats$seg_stat
CREATE OR REPLACE VIEW stats$seg_stat AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.dataobj#, s.obj#, s.ts#,
         s.logical_reads_total logical_reads, s.buffer_busy_waits_total buffer_busy_waits,
         s.db_block_changes_total db_block_changes, s.physical_reads_total physical_reads,
         s.physical_reads_direct_total direct_physical_reads,
         s.gc_cr_blocks_received_total gc_cr_blocks_received,
         s.gc_cu_blocks_received_total gc_current_blocks_received,
         s.gc_buffer_busy_total gc_buffer_busy, s.itl_waits_total itl_waits,
         s.row_lock_waits_total row_lock_waits,
         s.gc_cr_blocks_served_total global_cache_cr_blocks_served,
         s.gc_cu_blocks_served_total global_cache_cu_blocks_served
    FROM dba_hist_seg_stat s;

PROMPT ... stats$seg_stat_obj
CREATE OR REPLACE VIEW stats$seg_stat_obj AS
  SELECT o.dataobj#, o.obj#, o.ts#, o.dbid, o.owner, o.object_name, o.subobject_name,
         o.object_type, o.tablespace_name
    FROM dba_hist_seg_stat_obj o;

-- Instance Recovery Stats
PROMPT - Instance Recovery Stats
PROMPT ... stats$instance_recovery
CREATE OR REPLACE VIEW stats$instance_recovery AS
  SELECT r.snap_id, r.dbid, r.instance_number, r.recovery_estimated_ios, r.actual_redo_blks,
         r.target_redo_blks, r.log_file_size_redo_blks, r.log_chkpt_timeout_redo_blks,
         r.log_chkpt_interval_redo_blks, r.fast_start_io_target_redo_blks,
         r.target_mttr, r.estimated_mttr, r.ckpt_block_writes
    FROM dba_hist_instance_recovery r;

-- SharedPool and Buffer Stats
PROMPT - SharedPool and Buffer Stats
-- we do not have the total_cursors column anywhere
PROMPT ... stats$sql_statistics
CREATE OR REPLACE VIEW stats$sql_statistics AS
  SELECT s.snap_id, s.dbid, s.instance_number, s.total_sql, s.total_sql_mem,
         s.single_use_sql, s.single_use_sql_mem, NULL total_cursors
    FROM dba_hist_sql_summary s;

PROMPT ... stats$buffer_pool_statistics
CREATE OR REPLACE VIEW stats$buffer_pool_statistics AS
  SELECT b.snap_id, b.dbid, b.instance_number, b.id, b.name, b.block_size, b.set_msize,
         b.cnum_repl, b.cnum_write, b.cnum_set, b.buf_got, b.sum_write, b.sum_scan,
         b.free_buffer_wait, b.write_complete_wait, b.buffer_busy_wait, b.free_buffer_inspected,
         b.dirty_buffers_inspected, b.db_block_change, b.db_block_gets, b.consistent_gets,
         b.physical_reads, b.physical_writes
    FROM dba_hist_buffer_pool_stat b;

-- Wait Events
PROMPT - Wait Events
PROMPT ... stats$bg_event_summary
CREATE OR REPLACE VIEW stats$bg_event_summary AS
  SELECT e.snap_id, e.dbid, e.instance_number, e.event_name event, e.total_waits, e.total_timeouts, e.time_waited_micro
    FROM dba_hist_bg_event_summary e;

-- Enqueue Stats
PROMPT - Enqueue Stats
PROMPT ... stats$enqueue_statistics
CREATE OR REPLACE VIEW stats$enqueue_statistics AS
  SELECT e.snap_id, e.dbid, e.instance_number, e.eq_type, e.req_reason, e.total_req#, e.total_wait#,
         e.succ_req#, e.failed_req#, e.cum_wait_time, e.event#
    FROM dba_hist_enqueue_stat e;
CREATE OR REPLACE VIEW stats$enqueue_stat AS
  SELECT e.snap_id, e.dbid, e.instance_number, e.eq_type, e.req_reason, e.total_req#, e.total_wait#,
         e.succ_req#, e.failed_req#, e.cum_wait_time, e.event#
    FROM dba_hist_enqueue_stat e;

-- Undo Stats
PROMPT - Undo Statistics
PROMPT ... stats$undostat
CREATE OR REPLACE VIEW stats$undostat AS
  SELECT u.begin_time, u.end_time, u.snap_id, u.dbid, u.instance_number, u.undotsn, u.undoblks,
         u.txncount, u.maxquerylen, u.maxquerysqlid maxqueryid, u.maxconcurrency, u.unxpstealcnt,
         u.unxpblkrelcnt, u.unxpblkreucnt, u.expstealcnt, u.expblkrelcnt, u.expblkreucnt,
         u.ssolderrcnt, u.nospaceerrcnt, u.activeblks, u.unexpiredblks, u.expiredblks, u.tuned_undoretention
    FROM dba_hist_undostat u;

PROMPT ... stats$rollstat (dummy)
CREATE OR REPLACE VIEW stats$rollstat AS
  SELECT NULL snap_id, NULL dbid, NULL instance_number, NULL usn, NULL extents, NULL rssize,
         NULL writes, NULL xacts, NULL gets, NULL waits, NULL optsize, NULL hwmsize,
         NULL shrinks, NULL wraps, NULL extends, NULL aveshrink, NULL aveactive
    FROM DUAL
   WHERE 0=1;

-- Latch Misses Summary
PROMPT - Latch Misses Summary
PROMPT ... stats$latch_misses_summary
CREATE OR REPLACE VIEW stats$latch_misses_summary AS
  SELECT m.snap_id, m.dbid, m.instance_number, m.parent_name, m.where_in_code,
         m.nwfail_count, m.sleep_count, m.wtr_slp_count
    FROM dba_hist_latch_misses_summary m;

-- Cachesize Statistics
PROMPT - Cachesize Statistics
PROMPT ... stats$rowcache_summary
CREATE OR REPLACE VIEW stats$rowcache_summary AS
  SELECT r.snap_id, r.dbid, r.instance_number, r.parameter, r.total_usage, r.usage, r.gets, r.getmisses,
         r.scans, r.scanmisses, r.scancompletes, r.modifications, r.flushes,
         r.dlm_requests, r.dlm_conflicts, r.dlm_releases
    FROM dba_hist_rowcache_summary r;

PROMPT ... stats$librarycache
CREATE OR REPLACE VIEW stats$librarycache AS
  SELECT l.snap_id, l.dbid, l.instance_number, l.namespace, l.gets, l.gethits, l.pins, l.pinhits,
         l.reloads, l.invalidations, l.dlm_lock_requests, l.dlm_pin_requests, l.dlm_pin_releases,
         l.dlm_invalidation_requests, l.dlm_invalidations
    FROM dba_hist_librarycache l;

PROMPT
PROMPT ===========================================================
PROMPT Now we need some stored procedure stuff for compatibility
PROMPT ===========================================================
PROMPT - package header for the statspack dummy package (taken from 10g)
CREATE OR REPLACE PACKAGE statspack AS
  PROCEDURE stat_changes
      ( bid           IN  number
      , eid           IN  number
      , db_ident      IN  number
      , inst_num      IN  number
      , parallel      IN  varchar2
      , lhtr    OUT number,     bfwt   OUT number
      , tran    OUT number,     chng   OUT number
      , ucal    OUT number,     urol   OUT number
      , rsiz    OUT number
      , phyr    OUT number,     phyrd  OUT number
      , phyrdl  OUT number,     phyrc  OUT number
      , phyw    OUT number,     ucom   OUT number
      , prse    OUT number,     hprse  OUT number
      , recr    OUT number,     gets   OUT number
      , slr     OUT number
      , rlsr    OUT number,     rent   OUT number
      , srtm    OUT number,     srtd   OUT number
      , srtr    OUT number,     strn   OUT number
      , lhr     OUT number
      , bbc     OUT varchar2,   ebc    OUT varchar2
      , bsp     OUT varchar2,   esp    OUT varchar2
      , blb     OUT varchar2
      , bs      OUT varchar2,   twt    OUT number
      , logc    OUT number,     prscpu OUT number
      , tcpu    OUT number,     exe    OUT number
      , prsela  OUT number
      , bspm    OUT number,     espm   OUT number
      , bfrm    OUT number,     efrm   OUT number
      , blog    OUT number,     elog   OUT number
      , bocur   OUT number,     eocur  OUT number
      , bpgaalloc OUT number,   epgaalloc OUT number
      , bsgaalloc OUT number,   esgaalloc OUT number
      , bnprocs OUT number,     enprocs OUT number
      , timstat OUT varchar2,   statlvl OUT varchar2
      , bncpu   OUT number,     encpu  OUT number     -- OS Stat
      , bpmem   OUT number,     epmem  OUT number
      , blod    OUT number,     elod   OUT number
      , itic    OUT number,     btic   OUT number
      , iotic   OUT number,     rwtic  OUT number
      , utic    OUT number,     stic   OUT number
      , vmib    OUT number,     vmob   OUT number
      , oscpuw  OUT number
      , dbtim   OUT number,     dbcpu  OUT number     -- Time Model
      , bgela   OUT number,     bgcpu  OUT number
      , prstela OUT number,     sqleela OUT number
      , conmela OUT number
      , dmsd    OUT number,     dmfc   OUT number     -- begin RAC
      , dmsi    OUT number
      , pmrv    OUT number,     pmpt   OUT number
      , npmrv   OUT number,     npmpt  OUT number
      , dbfr    OUT number
      , dpms    OUT number,     dnpms  OUT number
      , glsg    OUT number,     glag   OUT number
      , glgt    OUT number
      , gccrrv  OUT number,     gccrrt OUT number,     gccrfl OUT number
      , gccurv  OUT number,     gccurt OUT number,     gccufl OUT number
      , gccrsv  OUT number
      , gccrbt  OUT number,     gccrft OUT number
      , gccrst  OUT number,     gccusv OUT number
      , gccupt  OUT number,     gccuft OUT number
      , gccust  OUT number
      , msgsq   OUT number,     msgsqt  OUT number
      , msgsqk  OUT number,     msgsqtk OUT number
      , msgrq   OUT number,     msgrqt  OUT number    -- end RAC
  );
END statspack;
/

PROMPT - package body for the very same package (taken from 10g code)
CREATE OR REPLACE PACKAGE BODY statspack AS
  PROCEDURE stat_changes
   /* Returns a set of differences of the values from corresponding pairs
      of rows in STATS$SYSSTAT, STATS$LIBRARYCACHE and STATS$WAITSTAT,
      -> stats$pgastat, stats$sga, stats$sys_time_model, stats$osstat,
      -> stats$time_model_statname, stats$system_event, stats$latch,
      -> stats$idle_event, stats$sgastat, stats$osstatname,
      -> stats$sesstat, stats$dlm_misc, stats$cr_block_server
      based on the begin and end (bid, eid) snapshot id's specified.
      This procedure is the only call to STATSPACK made by the statsrep 
      report.
      Modified to include multi-db support.
   */
      ( bid           IN  number
      , eid           IN  number
      , db_ident      IN  number
      , inst_num      IN  number
      , parallel      IN  varchar2
      , lhtr    OUT number,     bfwt   OUT number
      , tran    OUT number,     chng   OUT number
      , ucal    OUT number,     urol   OUT number
      , rsiz    OUT number
      , phyr    OUT number,     phyrd  OUT number
      , phyrdl  OUT number,     phyrc  OUT number
      , phyw    OUT number,     ucom   OUT number
      , prse    OUT number,     hprse  OUT number
      , recr    OUT number,     gets   OUT number
      , slr     OUT number
      , rlsr    OUT number,     rent   OUT number
      , srtm    OUT number,     srtd   OUT number
      , srtr    OUT number,     strn   OUT number
      , lhr     OUT number
      , bbc     OUT varchar2,   ebc    OUT varchar2
      , bsp     OUT varchar2,   esp    OUT varchar2
      , blb     OUT varchar2
      , bs      OUT varchar2,   twt    OUT number
      , logc    OUT number,     prscpu OUT number
      , tcpu    OUT number,     exe    OUT number
      , prsela  OUT number
      , bspm    OUT number,     espm   OUT number
      , bfrm    OUT number,     efrm   OUT number
      , blog    OUT number,     elog   OUT number
      , bocur   OUT number,     eocur  OUT number
      , bpgaalloc OUT number,   epgaalloc OUT number
      , bsgaalloc OUT number,   esgaalloc OUT number
      , bnprocs OUT number,     enprocs OUT number
      , timstat OUT varchar2,   statlvl OUT varchar2
      , bncpu   OUT number,     encpu  OUT number     -- OS Stat
      , bpmem   OUT number,     epmem  OUT number
      , blod    OUT number,     elod   OUT number
      , itic    OUT number,     btic   OUT number
      , iotic   OUT number,     rwtic  OUT number
      , utic    OUT number,     stic   OUT number
      , vmib    OUT number,     vmob   OUT number
      , oscpuw  OUT number
      , dbtim   OUT number,     dbcpu  OUT number     -- Time Model
      , bgela   OUT number,     bgcpu  OUT number
      , prstela OUT number,     sqleela OUT number
      , conmela OUT number
      , dmsd    OUT number,     dmfc   OUT number     -- begin RAC
      , dmsi    OUT number
      , pmrv    OUT number,     pmpt   OUT number
      , npmrv   OUT number,     npmpt  OUT number
      , dbfr   OUT number
      , dpms    OUT number,     dnpms  OUT number
      , glsg    OUT number,     glag   OUT number
      , glgt    OUT number
      , gccrrv  OUT number,     gccrrt OUT number,     gccrfl OUT number
      , gccurv  OUT number,     gccurt OUT number,     gccufl OUT number
      , gccrsv  OUT number
      , gccrbt  OUT number,     gccrft OUT number
      , gccrst  OUT number,     gccusv OUT number
      , gccupt  OUT number,     gccuft OUT number
      , gccust  OUT number
      , msgsq   OUT number,     msgsqt  OUT number
      , msgsqk  OUT number,     msgsqtk OUT number
      , msgrq   OUT number,     msgrqt  OUT number    -- end RAC
      ) is

      bval           number;   
      eval           number;
      l_b_session_id number;                         /* begin session id */
      l_b_serial#    number;                         /* begin serial# */
      l_e_session_id number;                         /* end session id */
      l_e_serial#    number;                         /* end serial# */
      l_b_timstat    varchar2(20);        /* timed_statistics begin value */
      l_e_timstat    varchar2(20);        /* timed_statistics end   value */
      l_b_statlvl    varchar2(40);        /* statistics_level begin value */
      l_e_statlvl    varchar2(40);        /* statistics_level end   value */

      /* ---------------------------------------------------------------- */

      function LIBRARYCACHE_HITRATIO RETURN number is

      /* Returns Library cache hit ratio for the begin and end (bid, eid) 
         snapshot id's specified
      */

         cursor LH (i_snap_id number) is
            select sum(pins), sum(pinhits)
              from stats$librarycache
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         bpsum number;  
         bhsum number;    
         epsum number;
         ehsum number;

      begin

         if not LH%ISOPEN then open LH (bid); end if;
         fetch LH into bpsum, bhsum;
         if LH%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$librarycache');
         end if; close LH;

         if not LH%ISOPEN then open LH (eid); end if;
         fetch LH into epsum, ehsum;
         if LH%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$librarycache');

         end if; close LH;

         return (ehsum - bhsum) / (epsum - bpsum);

      end LIBRARYCACHE_HITRATIO;
         
         
      /* ---------------------------------------------------------------- */

      function GET_PARAM (i_name varchar2, i_beid number) RETURN varchar2 is

      /* Returns the value for the init.ora parameter for the snapshot
         specified.
      */

         l_name    stats$parameter.name%type := i_name;
         par_value stats$parameter.value%type;

         cursor PARAMETER is
            select value
              from stats$parameter
             where snap_id         = i_beid
               and dbid            = db_ident
               and instance_number = inst_num
               and (   name  = '__' || i_name
                    or name  = i_name
                   )
             order by name;

      begin

         if not PARAMETER%ISOPEN then open PARAMETER; end if;
         fetch PARAMETER into par_value;
         if PARAMETER%NOTFOUND then
            raise_application_error
                        (-20100,'Missing Init.ora parameter '|| i_name || ' in snap ' || i_beid);
         end if; close PARAMETER;

         return par_value;

      end GET_PARAM;

      /* ---------------------------------------------------------------- */

      function GET_SYSSTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the System Statistic for the snapshot
         specified.
      */

         cursor SYSSTAT is
            select value
              from stats$sysstat
             where snap_id         = i_beid
               and dbid            = db_ident
               and instance_number = inst_num
               and name            = i_name;

         stat_value varchar2(512);

      begin

         if not SYSSTAT%ISOPEN then open SYSSTAT; end if;
         fetch SYSSTAT into stat_value;
         if SYSSTAT%NOTFOUND then
            raise_application_error
                        (-20100,'Missing System Statistic '|| i_name);
         end if; close SYSSTAT;

         return stat_value;

      end GET_SYSSTAT;

      /* ---------------------------------------------------------------- */

      function GET_OSSTAT (i_osstat_id number, i_beid number) RETURN number is

      /* Returns the value for the OSStat Statistic for the snapshot
         specified.
      */

         cursor OSSTAT is
            select value
             from stats$osstat os
            where os.snap_id         = i_beid
              and os.dbid            = db_ident
              and os.instance_number = inst_num
              and os.osstat_id       = i_osstat_id;

         stat_value number := null;

      begin

         if not OSSTAT%ISOPEN then open OSSTAT; end if;
         fetch OSSTAT into stat_value;
         if OSSTAT%NOTFOUND then
            null;
         end if; close OSSTAT;

         return stat_value;

      end GET_OSSTAT;

      /* ---------------------------------------------------------------- */

      function GET_PGASTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the PGAStat Statistic for the snapshot
         specified.
      */

         cursor PGASTAT is
           select value
             from stats$pgastat
            where snap_id         = i_beid
              and dbid            = db_ident
              and instance_number = inst_num
              and name            = i_name;

         stat_value number:= null;

      begin

         If not PGASTAT%ISOPEN then open PGASTAT; end if;
         fetch PGASTAT into stat_value;
         if PGASTAT%NOTFOUND then
            null;
         end if; close PGASTAT;

         return stat_value;

      end GET_PGASTAT;

      /* ---------------------------------------------------------------- */

      function GET_SGA (i_beid number) RETURN number is

      /* Returns the total SGA size
      */

         cursor SGA is
           select sum(value)
             from stats$sga
            where snap_id         = i_beid
              and dbid            = db_ident
              and instance_number = inst_num;

         stat_value number;

      begin

         if not SGA%ISOPEN then open SGA; end if;
         fetch SGA into stat_value;
         if SGA%NOTFOUND then
            raise_application_error
                        (-20100,'Unable to calculate total SGA Size');
         end if; close SGA;

         return stat_value;

      end GET_SGA;

      /* ---------------------------------------------------------------- */

      function GET_SYS_TIME_MODEL (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the Sys Time Model Statistic for the snapshot
         specified.
      */

         cursor STM is
           select value
             from stats$sys_time_model os
                , stats$time_model_statname tms
            where os.snap_id         = i_beid
              and os.dbid            = db_ident
              and os.instance_number = inst_num
              and os.stat_id         = tms.stat_id
              and tms.stat_name      = i_name;

         stat_value number := null;

      begin

         if not STM%ISOPEN then open STM; end if;
         fetch STM into stat_value;
         if STM%NOTFOUND then
            null;
         end if; close STM;

         return stat_value;

      end GET_SYS_TIME_MODEL;

      /* ---------------------------------------------------------------- */

      function BUFFER_WAITS RETURN number is

      /* Returns the total number of waits for all buffers in the interval
         specified by the begin and end snapshot id's (bid, eid)
      */

         cursor BW (i_snap_id number) is
            select sum(wait_count)
              from stats$waitstat
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         bbwsum number;  ebwsum number;

      begin

         if not BW%ISOPEN then open BW (bid); end if;
         fetch BW into bbwsum;
         if BW%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$waitstat');
         end if; close BW;

         if not BW%ISOPEN then open BW (eid); end if;
         fetch BW into ebwsum;
         if BW%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$waitstat');
         end if; close BW;

         return ebwsum - bbwsum;

      end BUFFER_WAITS;

      /* ---------------------------------------------------------------- */

      function BUFFER_GETS RETURN number is

      /* Returns the total number of buffers gets from cache in the interval
         specified by the begin and end snapshot id's (bid, eid)
      */

         cursor BG (i_snap_id number) is
            select sum(value)
              from stats$sysstat
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num
               and name in ('consistent gets from cache','db block gets from cache');

         bbgval number;  ebgval number;

      begin

         if not BG%ISOPEN then open BG (bid); end if;
         fetch BG into bbgval;
         if BG%NOTFOUND then
            raise_application_error
              (-20100,'Missing start value for stats$sysstat (db block/consistent gets from cache statistic)');
         end if; close BG;

         if not BG%ISOPEN then open BG (eid); end if;
         fetch BG into ebgval;
         if BG%NOTFOUND then
            raise_application_error
              (-20100,'Missing end value for stats$sysstat (db block/consistent gets from cache statistic)');
         end if; close BG;

         return ebgval - bbgval;

      end BUFFER_GETS;

      /* ---------------------------------------------------------------- */

      function TOTAL_EVENT_TIME RETURN number is

      /* Returns the total amount of time waited for events for
         the interval specified by the begin and end snapshot id's 
         (bid, eid).  This excludes idle wait events.
      */

         cursor WAITS (i_snap_id number) is
            select sum(time_waited_micro)
              from stats$system_event
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num
               and event not in (select event from stats$idle_event);

         bwaittime number;
         ewaittime number;

      begin

         if not WAITS%ISOPEN then open WAITS (bid); end if;
         fetch WAITS into bwaittime;
         if WAITS%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$system_event');
         end if; close WAITS;

         if not WAITS%ISOPEN then open WAITS (eid); end if;
         fetch WAITS into ewaittime;
         if WAITS%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$system_event');
         end if; close WAITS;

         return ewaittime - bwaittime;

      end TOTAL_EVENT_TIME;

      /* ---------------------------------------------------------------- */

      function LATCH_HITRATIO return NUMBER is

      /* Returns the latch hit ratio specified by the begin and 
         end snapshot id's (bid, eid)
      */

         cursor GETS_MISSES (i_snap_id number) is
            select sum(gets), sum(misses)
              from stats$latch
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         blget number;  -- beginning latch gets
         blmis number;  -- beginning latch misses
         elget number;  -- end latch gets
         elmis number;  -- end latch misses

      begin

         if not GETS_MISSES%ISOPEN then open GETS_MISSES (bid); end if;
         fetch GETS_MISSES into blget, blmis;
         if GETS_MISSES%NOTFOUND then
            raise_application_error
                (-20100,'Missing start value for STATS$LATCH gets and misses');
         end if; close GETS_MISSES;

         if not GETS_MISSES%ISOPEN then open GETS_MISSES (eid); end if;
         fetch GETS_MISSES into elget, elmis;
         if GETS_MISSES%NOTFOUND then
            raise_application_error
                (-20100,'Missing end value for STATS$LATCH gets and misses');
         end if; close GETS_MISSES;

         return ( ( elmis - blmis ) / ( elget - blget ) );

      end LATCH_HITRATIO;

      /* ---------------------------------------------------------------- */

      function SGASTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the bytes used by i_name in the shared pool
         for the begin or end snapshot (bid, eid) specified
      */

      cursor bytes_used is
        select bytes
          from stats$sgastat
         where snap_id         = i_beid
           and dbid            = db_ident
           and instance_number = inst_num
           and pool            in ('shared pool', 'all pools')
           and name            = i_name; 

       total_bytes number;

       begin
        if i_name = 'total_shared_pool' then
          select sum(bytes)
            into total_bytes
            from stats$sgastat
           where snap_id         = i_beid
             and dbid            = db_ident
             and instance_number = inst_num
             and pool            in ('shared pool','all pools');
        else
          open bytes_used; fetch bytes_used into total_bytes;
          if bytes_used%notfound then
             raise_application_error
                         (-20100,'Missing value for SGASTAT: '||i_name);
          end if;
          close bytes_used;
        end if;
 
         return total_bytes;
      end SGASTAT;

      /* ---------------------------------------------------------------- */

      function SYSDIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the Statspack schema includes data from a prior
         server release, this function returns NULL for statistics which
         do not appear in both the begin and end snapshots
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$sysstat
       where snap_id         = i_snap_id
         and dbid            = db_ident
         and instance_number = inst_num
         and name            = i_name;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer SYSSTAT statistic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end SYSDIF;

      /* ---------------------------------------------------------------- */

      function OSSTAT_DIF (i_osstat_id number) RETURN number is

      /* Returns the difference between statistics for the OSStat statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the data being queried is from a prior release
         which did not have the statistic requested, this function
         returns 0.
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$osstat os
           , stats$osstatname osn
       where os.snap_id         = i_snap_id
         and os.dbid            = db_ident
         and os.instance_number = inst_num
         and os.osstat_id       = i_osstat_id;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer statistic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for OSStat Id : '||i_osstat_id);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for OSStat Id: '||i_osstat_id);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end OSSTAT_DIF;

      /* ---------------------------------------------------------------- */

      function SYS_TIME_MODEL_DIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the Time Model statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the data being queried is from a prior release
         which did not have the statistic requested, this function
         returns 0.
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$sys_time_model      stm
           , stats$time_model_statname tms
       where stm.snap_id         = i_snap_id
         and stm.dbid            = db_ident
         and stm.instance_number = inst_num
         and stm.stat_id         = tms.stat_id
         and tms.stat_name       = i_name;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

               /* this is likely a newer statitic which did not
                 exist for this database version    */
              return 0;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for SYS_TIME_MODEL statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for SYS_TIME_MODEL statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end SYS_TIME_MODEL_DIF;

      /* ---------------------------------------------------------------- */

      function SESDIF (st_name varchar2) RETURN number is

      /* Returns the difference between statistics values for the 
         statistic name specified for the interval between the begin and end 
         snapshot id's (bid, eid), for the session monitored for that
         snapshot
      */

      cursor SE (i_snap_id number) is
         select ses.value 
           from stats$sysstat sys
              , stats$sesstat ses
          where sys.snap_id     = i_snap_id
            and ses.snap_id     = i_snap_id
            and ses.dbid        = db_ident
            and sys.dbid        = db_ident
            and ses.instance_number = inst_num
            and sys.instance_number = inst_num
            and ses.statistic#  = sys.statistic#
            and sys.name        = st_name;

      begin
         /* Get start value */
         open SE (bid); fetch SE into bval;
         if SE%notfound then
           eval :=0;
         end if; close SE;
 
         /* Get end value */
         open SE (eid); fetch SE into eval;
         if SE%notfound then
           eval :=0;
         end if; close SE;
 
         /* Return difference */
         return eval - bval;
      end SESDIF;

/* ---------------------------------------------------------------- */

      function DLMDIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the statistic
         name specified for the interval between the begin and end
         snapshot id's (bid, eid)

         In the case the Statspack schema includes data from a prior
         server release, this function returns NULL for statistics which
         do not appear in both the begin and end snapshots
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor DLM (i_snap_id number) is
      select value
        from stats$dlm_misc
       where snap_id         = i_snap_id
         and dbid            = db_ident
         and instance_number = inst_num
         and name            = i_name;

      
      begin

         /* Get start value */
         open DLM (bid); fetch DLM into bval;
         if DLM%notfound then
            beg_val_missing := true;
         end if; close DLM;

         /* Get end value */
         open DLM (eid); fetch DLM into eval;
         if DLM%notfound then
            end_val_missing := true;
         end if; close DLM;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer DLM_MISC statitic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end DLMDIF;


/* ---------------------------------------------------------------- */

      function RACFLSTAT (i_name varchar2) return number is

      /* Computes the difference between CR and CURRENT block
         flush statistics for the interval between begin and end
         snapshot id's (bid, eid).

         In the case the statistic does not appear in one of the
         snapshots or the argument value is wrong, the function returns 0.
      */

      flushes                      number := 0;


      begin

         if  i_name = 'cr_flushes'  then
           select e.flushes - b.flushes into flushes
             from stats$cr_block_server b
                , stats$cr_block_server e
            where b.snap_id          = bid
              and b.dbid             = db_ident
              and b.instance_number  = inst_num
              and e.snap_id          = eid
              and e.dbid             = db_ident
              and e.instance_number  = inst_num;
 
         elsif  i_name = 'current_flushes'  then
           select (e.flush1+e.flush10+e.flush100+e.flush1000+e.flush10000)
                    - (b.flush1+b.flush10+b.flush100+b.flush1000+b.flush10000)
                  into flushes
             from stats$current_block_server b
                , stats$current_block_server e
            where b.snap_id         = bid
              and b.dbid            = db_ident
              and b.instance_number = inst_num
              and e.snap_id         = eid
              and e.dbid            = db_ident
              and e.instance_number = inst_num;
         end if;

         return flushes;

      exception
        when NO_DATA_FOUND then
           /*  begin or end value does not exist - return 0 */
          return 0;


      end RACFLSTAT;


   /* ------------------------------------------------------------------- */
 

   begin     /* main procedure body of STAT_CHANGES */

      lhtr   := LIBRARYCACHE_HITRATIO;
      bfwt   := BUFFER_WAITS;
      lhr    := LATCH_HITRATIO;
      chng   := SYSDIF('db block changes');
      ucal   := SYSDIF('user calls');
      urol   := SYSDIF('user rollbacks');
      ucom   := SYSDIF('user commits');
      tran   := ucom + urol;
      rsiz   := SYSDIF('redo size');
      phyr   := SYSDIF('physical reads');
      phyrd  := SYSDIF('physical reads direct');
      phyrdl := SYSDIF('physical reads direct (lob)');
      phyrc  := SYSDIF('physical reads cache');
      phyw   := SYSDIF('physical writes');
      hprse  := SYSDIF('parse count (hard)');
      prse   := SYSDIF('parse count (total)');
      gets   := BUFFER_GETS;
      slr    := SYSDIF('session logical reads');
      recr   := SYSDIF('recursive calls');
      rlsr   := SYSDIF('redo log space requests');
      rent   := SYSDIF('redo entries');
      srtm   := SYSDIF('sorts (memory)');
      srtd   := SYSDIF('sorts (disk)');
      srtr   := SYSDIF('sorts (rows)');
      logc   := SYSDIF('logons cumulative');
      prscpu := SYSDIF('parse time cpu');
      prsela := SYSDIF('parse time elapsed');
      tcpu   := SYSDIF('CPU used by this session');
      exe    := SYSDIF('execute count');
      bs     := GET_PARAM('db_block_size', bid);
      bbc    := GET_PARAM('db_block_buffers', bid) * bs;
      if bbc = 0 then
        bbc  :=   GET_PARAM('db_cache_size', bid)
                + GET_PARAM('db_keep_cache_size', bid)
                + GET_PARAM('db_recycle_cache_size', bid)
                + GET_PARAM('db_2k_cache_size', bid)
                + GET_PARAM('db_4k_cache_size', bid)
                + GET_PARAM('db_8k_cache_size', bid)
                + GET_PARAM('db_16k_cache_size', bid)
                + GET_PARAM('db_32k_cache_size', bid);
      end if;
      ebc  := GET_PARAM('db_block_buffers', eid) * bs;
      if ebc = 0 then
        ebc  :=   GET_PARAM('db_cache_size', eid)
                + GET_PARAM('db_keep_cache_size', eid)
                + GET_PARAM('db_recycle_cache_size', eid)
                + GET_PARAM('db_2k_cache_size', eid)
                + GET_PARAM('db_4k_cache_size', eid)
                + GET_PARAM('db_8k_cache_size', eid)
                + GET_PARAM('db_16k_cache_size', eid)
                + GET_PARAM('db_32k_cache_size', eid);
      end if;
      bsp  := GET_PARAM('shared_pool_size', bid);
      esp  := GET_PARAM('shared_pool_size', eid);
      blb  := GET_PARAM('log_buffer', bid);
      twt  := TOTAL_EVENT_TIME;     -- total wait time for all non-idle events
      -- get value from __, rather than summing sgastat
      bspm := bsp;
      espm := esp;
      bfrm := SGASTAT('free memory', bid);
      efrm := SGASTAT('free memory', eid);
      blog := GET_SYSSTAT('logons current', bid);
      elog := GET_SYSSTAT('logons current', eid);
      bocur := GET_SYSSTAT('opened cursors current', bid);
      eocur := GET_SYSSTAT('opened cursors current', eid);
      bpgaalloc := GET_PGASTAT('total PGA allocated', bid);
      epgaalloc := GET_PGASTAT('total PGA allocated', eid);
      bsgaalloc := GET_SGA(bid);
      esgaalloc := GET_SGA(eid);
      bnprocs   := GET_PGASTAT('process count', bid);
      enprocs   := GET_PGASTAT('process count', eid);
      l_b_timstat := GET_PARAM('timed_statistics', bid);
      l_e_timstat := GET_PARAM('timed_statistics', eid);
      if (l_b_timstat = l_e_timstat) then
         timstat := l_b_timstat;
      else
         timstat := 'INCONSISTENT';
      end if;
      l_b_statlvl := upper(GET_PARAM('statistics_level', bid));
      l_e_statlvl := upper(GET_PARAM('statistics_level', eid));
      if    (l_b_statlvl = l_e_statlvl) then
         statlvl := l_b_statlvl;
      elsif (l_b_statlvl  = 'BASIC' and l_e_statlvl != 'BASIC')
         or (l_b_statlvl != 'BASIC' and l_e_statlvl  = 'BASIC')  then
         -- Timed Stats may be inconsistent and Stats Level stats inconsistent
         statlvl := 'INCONSISTENT_BASIC';
      elsif (l_b_statlvl != l_e_statlvl) then
         -- Stat level changed from TYPICAL/ADVANCED to ADVANCED/TYPICAL
         -- so timed stats and stats level stats will still be ok
         statlvl := 'INCONSISTENT';
      end if;

      -- OS Stat
      bncpu := GET_OSSTAT(0, bid);    -- NUM_CPUS
      encpu := GET_OSSTAT(0, eid);    -- NUM_CPUS
      bpmem := GET_OSSTAT(1008, bid); -- PHYSICAL_MEMORY_BYTES
      epmem := GET_OSSTAT(1008, eid); -- PHYSICAL_MEMORY_BYTES
      blod  := GET_OSSTAT(15, bid);   -- LOAD
      elod  := GET_OSSTAT(15, eid);   -- LOAD

      itic  := OSSTAT_DIF(1);      -- IDLE_TIME
      btic  := OSSTAT_DIF(2);      -- BUSY_TIME
      iotic := OSSTAT_DIF(5);      -- IOWAIT_TIME      - solaris
      rwtic := OSSTAT_DIF(14);     -- RSRC_MGR_CPU_WAIT_TIME
      utic  := OSSTAT_DIF(3);      -- USER_TIME
      stic  := OSSTAT_DIF(4);      -- SYS_TIME
      oscpuw:= OSSTAT_DIF(13);     -- OS_CPU_WAIT_TIME - solaris
      vmib  := OSSTAT_DIF(1000);   -- VM_IN_BYTES
      vmob  := OSSTAT_DIF(1001);   -- VM_OUT_BYTES

      -- Time Model
      dbtim   := SYS_TIME_MODEL_DIF('DB time');
      dbcpu   := SYS_TIME_MODEL_DIF('DB CPU');
      bgela   := SYS_TIME_MODEL_DIF('background elapsed time');
      bgcpu   := SYS_TIME_MODEL_DIF('background cpu time');
      prstela := SYS_TIME_MODEL_DIF('parse time elapsed');
      sqleela := SYS_TIME_MODEL_DIF('sql execute elapsed time');
      conmela := SYS_TIME_MODEL_DIF('connection management call elapsed');

      /*  Do we want to report on RAC-specific statistics? Check
          in procedure variable "parallel".
      */

      if parallel = 'YES' then

        dmsd     := DLMDIF('messages sent directly');
        dmfc     := DLMDIF('messages flow controlled');
        dmsi     := DLMDIF('messages sent indirectly');
        pmrv     := DLMDIF('gcs msgs received');
        pmpt     := DLMDIF('gcs msgs process time(ms)');
        npmrv    := DLMDIF('ges msgs received');
        npmpt    := DLMDIF('ges msgs process time(ms)');
        dbfr     := SYSDIF('DBWR fusion writes');
        dpms     := SYSDIF('gcs messages sent');
        dnpms    := SYSDIF('ges messages sent');
        glsg     := SYSDIF('global enqueue gets sync');
        glag     := SYSDIF('global enqueue gets async');
        glgt     := SYSDIF('global enqueue get time');
        gccrrv   := SYSDIF('gc cr blocks received');
        gccrrt   := SYSDIF('gc cr block receive time');
        gccurv   := SYSDIF('gc current blocks received');
        gccurt   := SYSDIF('gc current block receive time');
        gccrsv   := SYSDIF('gc cr blocks served');
        gccrbt   := SYSDIF('gc cr block build time');
        gccrft   := SYSDIF('gc cr block flush time');
        gccrst   := SYSDIF('gc cr block send time');
        gccusv   := SYSDIF('gc current blocks served');
        gccupt   := SYSDIF('gc current block pin time');
        gccuft   := SYSDIF('gc current block flush time');
        gccust   := SYSDIF('gc current block send time');
        msgsq    := DLMDIF('msgs sent queued');
        msgsqt   := DLMDIF('msgs sent queue time (ms)');
        msgsqk   := DLMDIF('msgs sent queued on ksxp');
        msgsqtk  := DLMDIF('msgs sent queue time on ksxp (ms)');
        msgrqt   := DLMDIF('msgs received queue time (ms)');
        msgrq    := DLMDIF('msgs received queued');
        gccrfl   := RACFLSTAT('cr_flushes');
        gccufl   := RACFLSTAT('current_flushes');

     end if;


      /*  Determine if we want to report on session-specific statistics.
          Check that the session is the same one for both snapshots.
      */
      select session_id
           , serial#
        into l_b_session_id
           , l_b_serial#
        from stats$snapshot
       where snap_id         = bid
         and dbid            = db_ident
         and instance_number = inst_num;

      select session_id
           , serial#
        into l_e_session_id
           , l_e_serial#
        from stats$snapshot
       where snap_id         = eid
         and dbid            = db_ident
         and instance_number = inst_num;

      if (    (l_b_session_id = l_e_session_id)
          and (l_b_serial#    = l_e_serial#)
          and (l_b_session_id != 0)              ) then
         /*  we have a valid comparison - it is the
             same session - get number of tx performed 
             by this session */
         strn := SESDIF('user rollbacks') + SESDIF('user commits');
         if strn = 0 then
            /*  No new transactions */
            strn :=  1; 
         end if;
      else
         /*  No valid comparison can be made */
         strn :=1;          
      end if;

   end STAT_CHANGES;
END statspack;
/

PROMPT
PROMPT ===========================================================
PROMPT Finito
PROMPT ===========================================================
PROMPT

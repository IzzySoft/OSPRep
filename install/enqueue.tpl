<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Enqueue</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are Enqueues?</H3>
 <P>Enqueues are OS specific "Locks" using different modes. If an object
  protected by an enqueue is requested by another process in an incompatible
  mode, this request is put in a FiFo queue (if not requested with NOWAIT).
  Thus all requests are handled in the order of their appearance.</P>
 <H3>What do Enqueue waits stand for?</H3>
 <P>The <code>Enqueue</code> wait event may be an indication that something is
  either wrong with the code (should multiple sessions be serializing
  themselves against a common row?) or possibly the physical design (high
  activity on child tables with unindexed foreign keys, inadequate
  <A HREF="initrans.html"><CODE>INITRANS</CODE></A> or <CODE>MAXTRANS</CODE>
  values, etc.).</P>
 <H3>What actions can be taken?</H3>
 <P>You could check whether you have child tables with unindexed foreign key
  constraints, issuing the following statement either as <CODE>SYS</CODE> or
  <CODE>SYSTEM</CODE> user:
  <TABLE ALIGN="center"><TR><TD>
    <DIV CLASS="code" STYLE="width:35em">
    SELECT con.owner, con.table_name, co.column_name,<BR>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;con.constraint_name, i.index_name<BR>
    &nbsp;&nbsp;FROM dba_constraints con, dba_cons_columns co,<BR>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dba_ind_columns i<BR>
    &nbsp;WHERE con.owner NOT IN ('SYS','SYSTEM')<BR>
    &nbsp;&nbsp;&nbsp;AND con.constraint_type='R'<BR>
    &nbsp;&nbsp;&nbsp;AND co.owner NOT IN ('SYS','SYSTEM')<BR>
    &nbsp;&nbsp;&nbsp;AND i.table_owner NOT IN ('SYS','SYSTEM')<BR>
    &nbsp;&nbsp;&nbsp;AND con.owner=co.owner<BR>
    &nbsp;&nbsp;&nbsp;AND con.table_name=co.table_name<BR>
    &nbsp;&nbsp;&nbsp;AND con.constraint_name=co.constraint_name<BR>
    &nbsp;&nbsp;&nbsp;AND co.owner=i.table_owner(+)<BR>
    &nbsp;&nbsp;&nbsp;AND co.table_name=i.table_name(+)<BR>
    &nbsp;&nbsp;&nbsp;AND co.column_name=i.column_name(+)<BR>
    &nbsp;&nbsp;&nbsp;AND i.index_name IS NULL;</DIV>
  </TD></TR></TABLE>
  If there are any rows returned, you should create appropriate indexes for
  the columns reported that may then be used for the constraints. Be aware
  that, if a foreign key constraint consists of multiple columns of a table,
  all these columns must be included in ONE index in order for the index to
  be used.</P>
 <P>To see what indexes exist that <i>could</i> be used for the constraint, just
  ommit the last line (<CODE>index_name IS NULL</CODE>).</P>
 <P>Since this event also indicates that there are too many DML or DDL locks (or,
  maybe, a large number of sequences), increasing the
  <CODE>ENQUEUE_RESOURCES</CODE> parameter in the <CODE>init.ora</CODE> may
  help reduce these waits as well. To check the current values, execute the
  following statement as <CODE>SYS</CODE> or <CODE>SYSTEM</CODE>:
  <TABLE ALIGN="center"><TR><TD>
    <DIV CLASS="code" STYLE="width:28em">
    SELECT *<BR>
    &nbsp;&nbsp;FROM v$resource_limit<BR>
    &nbsp;WHERE resource_name='enqueue_resources'
    </DIV>
  </TD></TR></TABLE>
  Most important for your decision are the values of the columns
  <CODE>max_utilization</CODE>, <CODE>limit_value</CODE> and
  <CODE>initial_allocation</CODE>. If the first does not exceed either of the
  other two, there's nothing to do for you at this place: according to the
  Oracle documentation, Oracle automatically allocates additional enqueues
  (additional to <CODE>initial_allocation</CODE>) from the shared pool when
  needed, as long as this does not exceed the <CODE>limit_value</CODE>.</P>

</TD></TR></TABLE>

</BODY></HTML>

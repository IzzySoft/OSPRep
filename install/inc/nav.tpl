<html>
<head>
<title>Database Statistic Diagrams: Navigation</title>
<SCRIPT Language="JavaScript">
  function init(mode) {
    parent.dtype = mode;
    switch(mode) {
      case "cumul" :
      case "delta" : parent.dstat = parent.enq;
                     parent.dname = "Enqueues";
                     parent.arrname = 'enq';
		     break;
      case "ratio" : parent.dstat = parent.enqper;
                     parent.dname = "Enqueue Timeouts per Request (OK: &lt;&lt; 0.01)";
                     parent.arrname = 'enqper';
		     break;
    }
  }
</SCRIPT>
<LINK REL="stylesheet" TYPE="text/css" HREF="../{css}">
</HEAD><BODY>
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="2" ALIGN="center" STYLE="margin-top:30">
 <TR><TH CLASS="th_sub">Stats</TH></TR>
 <TR><TD ALIGN="center"><A HREF="cumul.html" TARGET="chart" onClick="init('cumul')">Cumul</A></TD></TR>
 <TR><TD ALIGN="center"><A HREF="cumave.html" TARGET="chart" onClick="init('cumul')">CumAvg</A></TD></TR>
 <TR><TD ALIGN="center"><A HREF="delta.html" TARGET="chart" onClick="init('delta')">Delta</A></TD></TR>
 <TR><TD ALIGN="center"><A HREF="ratio.html" TARGET="chart" onClick="init('ratio')">Ratio</A></TD></TR>
</TABLE>
</body>
</html>
bid = parent.bid;
eid = parent.eid;
dbup_id = parent.dbup_id;
if (maxval == 0 || isNaN(maxval)) maxval = 1;

// Create Diagram
function mkdiag() {
  var left  = Math.max(0,(document.body.clientWidth - 460) / 2);
  var right = left + 460;
  D.SetFrame(left, 120, right, 380);
 // ScreenLeftX, TopY, RightX, BottomY
  D.SetBorder(bid, eid, 0, maxval + maxval/20);
 // DiagLeftX, RightX, BottomY, TopY
  D.SetText("", "", "");
 // ScaleX, ScaleY, Title
  D.Draw("#DDDDDD", "#000000", false, "");
 // DrawColor, TextColor, isScaleText [, ToolTip [, Action]]
}

// Draw diagram for specified stat
function drawStat(stat) {
  parent.arrname = stat;
  switch(stat) {
    case "enq" :  parent.dstat = parent.enq;
                  parent.dname = "Enqueues";
		  break;
    case "freebuff" : parent.dstat = parent.freebuff;
                  parent.dname = "Free Buffer Waits";
		  break;
    case "busybuff": parent.dstat = parent.busybuff;
                  parent.dname = "Buffer Busy Waits";
		  break;
    case "fileseq" :  parent.dstat = parent.fileseq;
                  parent.dname = "DB File Sequential Reads";
		  break;
    case "filescat" :  parent.dstat = parent.filescat;
                  parent.dname = "DB File Scattered Reads";
		  break;
    case "lgwr" :  parent.dstat = parent.lgwr;
                  parent.dname = "LGWR Wait for Redo Copy";
		  break;
    case "lgsw" :  parent.dstat = parent.lgsw;
                  parent.dname = "Log File Switch Completion";
		  break;
    case "redoreq" :  parent.dstat = parent.redoreq;
                  parent.dname = "Redo Log Space Requests";
		  break;
    case "enqper" :  parent.dstat = parent.enqper;
                  parent.dname = "Enqueue Timeouts per Request (OK: &lt;&lt; 0.01)";
		  break;
    case "fbp"  : parent.dstat = parent.fbp;
                  parent.dname = "Free Buffers Inspected / Requested (OK: &lt;&lt; 0.1)";
		  break;
    case "libmiss" :  parent.dstat = parent.libmiss;
                  parent.dname = "Pct Library Cache HitMisses (OK: &lt; 10%)";
		  break;
    case "logon" :  parent.dstat = parent.logon;
                  parent.dname = "Logons";
		  break;
    case "opencur" :  parent.dstat = parent.opencur;
                  parent.dname = "Open Cursors";
		  break;
    case "cfr"  : parent.dstat = parent.cfr;
                  parent.dname = "Chained-Fetch-Ratio (OK: &lt; 10%)";
		  break;
    case "rpp"  : parent.dstat = parent.rpp;
                  parent.dname = "Pct Library Cache Reloads Per Pin (OK: &lt; 1%)";
		  break;
    case "ghr"  : parent.dstat = parent.ghr;
                  parent.dname = "Pct Library Cache GetHitRatio (OK: &gt; 90%)";
		  break;
    case "rcr"  : parent.dstat = parent.rcr;
                  parent.dname = "Pct Row Cache Ratio (OK: &lt; 15%)";
		  break;
    case "phyrd" : parent.dstat = parent.phyrd;
                  parent.dname = "Physical Reads per Snapshot (MB)";
		  break;
    case "phywrt" : parent.dstat = parent.phywrt;
                  parent.dname = "Physical Writes per Snapshot (MB)";
		  break;
  }
  location.reload();
}

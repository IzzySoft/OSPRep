bid = parent.bid;
eid = parent.eid;
if (maxval == 0) maxval = 1;

// Create Diagram
function mkdiag() {
  var left  = Math.max(0,(document.body.clientWidth - 460) / 2);
  var right = left + 460;
//  D.SetFrame(80, 120, 540, 380);
 // ScreenLeftX, TopY, RightX, BottomY
  D.SetFrame(left, 120, right, 380);
 // ScreenLeftX, TopY, RightX, BottomY
  D.SetBorder(bid, eid, 0, maxval + maxval/20);
 // DiagLeftX, RightX, BottomY, TopY
//  D.SetText("", "", "<B>"+parent.dname+"</B>");
 // ScaleX, ScaleY, Title
  D.SetText("", "", "");
 // ScaleX, ScaleY, Title
  D.Draw("#DDDDDD", "#000000", false, "");
 // DrawColor, TextColor, isScaleText [, ToolTip [, Action]]
}

// Draw diagram for specified stat
function drawStat(stat) {
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
                  parent.dname = "Enqueue Timeouts per Request";
		  break;
    case "libmiss" :  parent.dstat = parent.libmiss;
                  parent.dname = "Pct Library Cache HitMisses";
		  break;
  }
  location.reload();
}

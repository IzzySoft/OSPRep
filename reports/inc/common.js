bid = parent.bid;
eid = parent.eid;
max = parent.dstat[eid];
if (max == 0) max = 1;

// Create Diagram
function mkdiag() {
  D.SetFrame(80, 120, 540, 380);
 // ScreenLeftX, TopY, RightX, BottomY
  D.SetBorder(bid, eid, 0, max + max/20);
 // DiagLeftX, RightX, BottomY, TopY
  D.SetText("", "", "<B>"+parent.dname+"</B>");
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
  }
  location.reload();
}
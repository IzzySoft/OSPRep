bid = parent.bid;
eid = parent.eid;
max = parent.dstat[eid];
if (max == 0) max = 1;

// Create Diagram
function mkdiag() {
  // Center graph
  wwid = document.body.offsetWidth - 460; // Screen width w/o graph
  x1 = wwid/2;   // LeftX for graph
  x2 = x1 + 460; // RightX for graph
  D.SetFrame(x1, 140, x2, 400); // ScreenLeftX, TopY, RightX, BottomY
  // Set properties
  D.SetBorder(bid, eid, 0, max + max/20); // DiagLeftX, RightX, BottomY, TopY
  D.SetText("", "", "<B>"+parent.dname+"</B>"); // ScaleX, ScaleY, Title
  D.Draw("#DDDDDD", "#000000", false, ""); // DrawColor, TextColor, isScaleText [, ToolTip [, Action]]
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

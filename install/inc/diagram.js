// JavaScript Diagram Builder 2.0
// Copyright (c) 2002 Lutz Tautenhahn, all rights reserved.
//
// The Author grants you a non-exclusive, royalty free, license to use,
// modify and redistribute this software, provided that this copyright notice
// and license appear on all copies of the software.
// This software is provided "as is", without a warranty of any kind.

var _N_Dia=0, _N_Bar=0, _N_Box=0, _N_Dot=0, _N_Pix=0, _zIndex=0, _opera=0;
var _dSize = (navigator.appName == "Microsoft Internet Explorer") ? 1 : -1;
if (navigator.userAgent.search("Opera")>=0) { _dSize=-4; _opera=1; }
var _linux = (navigator.platform.search("Linux")>=0) ? 1 : 0;
var _nav4 = (document.layers) ? 1 : 0;

function Diagram()
{ this.XScale=1;
  this.YScale=1;
  this.ID="Dia"+_N_Dia; _N_Dia++; _zIndex++;
  this.zIndex=_zIndex;
  this.SetFrame=_SetFrame;
  this.SetBorder=_SetBorder;
  this.SetText=_SetText;
  this.ScreenX=_ScreenX;
  this.ScreenY=_ScreenY;
  this.RealX=_RealX;
  this.RealY=_RealY;
  this.Draw=_Draw;
  this.SetVisibility=_SetVisibility;
  this.SetTitle=_SetTitle;
  this.Delete=_Delete;
  return(this);
}
function _SetFrame(theLeft, theTop, theRight, theBottom)
{ this.left   = theLeft;
  this.right  = theRight;
  this.top    = theTop;
  this.bottom = theBottom;
}
function _SetBorder(theLeftX, theRightX, theBottomY, theTopY)
{ this.xmin = theLeftX;
  this.xmax = theRightX;
  this.ymin = theBottomY;
  this.ymax = theTopY;
}
function _SetText(theScaleX, theScaleY, theTitle)
{ this.xtext=theScaleX;
  this.ytext=theScaleY;
  this.title=theTitle;
}
function _ScreenX(theRealX)
{ return(Math.round((theRealX-this.xmin)/(this.xmax-this.xmin)*(this.right-this.left)+this.left));
}
function _ScreenY(theRealY)
{ return(Math.round((this.ymax-theRealY)/(this.ymax-this.ymin)*(this.bottom-this.top)+this.top));
}
function _RealX(theScreenX)
{ return(this.xmin+(this.xmax-this.xmin)*(theScreenX-this.left)/(this.right-this.left));
}
function _RealY(theScreenY)
{ return(this.ymax-(this.ymax-this.ymin)*(theScreenY-this.top)/(this.bottom-this.top));
}
function _sign(rr)
{ if (rr<0) return(-1); else return(1);
}
function _DateInterval(vv)
{ var bb=140*24*60*60*1000; //140 days
  if (vv>=bb) //140 days < 5 months
  { bb=8766*60*60*1000;//1 year
    if (vv<bb) //1 year 
      return(bb/12); //1 month
    if (vv<bb*2) //2 years 
      return(bb/6); //2 month
    if (vv<bb*5/2) //2.5 years
      return(bb/4); //3 month
    if (vv<bb*5) //5 years
      return(bb/2); //6 month
    if (vv<bb*10) //10 years
      return(bb); //1 year
    if (vv<bb*20) //20 years
      return(bb*2); //2 years
    if (vv<bb*50) //50 years
      return(bb*5); //5 years
    if (vv<bb*100) //100 years
      return(bb*10); //10 years
    if (vv<bb*200) //200 years
      return(bb*20); //20 years
    if (vv<bb*500) //500 years
      return(bb*50); //50 years
    return(bb*100); //100 years
  }
  bb/=2; //70 days
  if (vv>=bb) return(bb/5); //14 days
  bb/=2; //35 days
  if (vv>=bb) return(bb/5); //7 days
  bb/=7; bb*=4; //20 days
  if (vv>=bb) return(bb/5); //4 days
  bb/=2; //10 days
  if (vv>=bb) return(bb/5); //2 days
  bb/=2; //5 days
  if (vv>=bb) return(bb/5); //1 day
  bb/=2; //2.5 days
  if (vv>=bb) return(bb/5); //12 hours
  bb*=3; bb/=5; //1.5 day
  if (vv>=bb) return(bb/6); //6 hours
  bb/=2; //18 hours
  if (vv>=bb) return(bb/6); //3 hours
  bb*=2; bb/=3; //12 hours
  if (vv>=bb) return(bb/6); //2 hours
  bb/=2; //6 hours
  if (vv>=bb) return(bb/6); //1 hour
  bb/=2; //3 hours
  if (vv>=bb) return(bb/6); //30 mins
  bb/=2; //1.5 hours
  if (vv>=bb) return(bb/6); //15 mins
  bb*=2; bb/=3; //1 hour
  if (vv>=bb) return(bb/6); //10 mins
  bb/=3; //20 mins
  if (vv>=bb) return(bb/4); //5 mins
  bb/=2; //10 mins
  if (vv>=bb) return(bb/5); //2 mins
  bb/=2; //5 mins
  if (vv>=bb) return(bb/5); //1 min
  bb*=3; bb/=2; //3 mins
  if (vv>=bb) return(bb/6); //30 secs
  bb/=2; //1.5 mins
  if (vv>=bb) return(bb/6); //15 secs
  bb*=2; bb/=3; //1 min
  if (vv>=bb) return(bb/6); //10 secs
  bb/=3; //20 secs
  if (vv>=bb) return(bb/4); //5 secs
  bb/=2; //10 secs
  if (vv>=bb) return(bb/5); //2 secs
  return(bb/10); //1 sec
}
function _DateFormat(vv, ii, ttype)
{ var yy, mm, dd, hh, nn, ss, vv_date=new Date(vv);
  Month=new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  Weekday=new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
  if (ii>15*24*60*60*1000)
  { if (ii<365*24*60*60*1000)
    { vv_date.setTime(vv+15*24*60*60*1000);
      yy=vv_date.getYear()%100;
      if (yy<10) yy="0"+yy;
      mm=vv_date.getUTCMonth()+1;
      if (ttype==5) ;//You can add your own date format here
      if (ttype==4) return(Month[mm-1]);
      if (ttype==3) return(Month[mm-1]+" "+yy);
      return(mm+"/"+yy);
    }
    vv_date.setTime(vv+183*24*60*60*1000);
    yy=vv_date.getYear();
    return(yy);
  }
  vv_date.setTime(vv);
  mm=vv_date.getUTCMonth()+1;
  dd=vv_date.getUTCDate();
  ww=vv_date.getUTCDay();
  hh=vv_date.getUTCHours();
  nn=vv_date.getUTCMinutes(); 
  ss=vv_date.getUTCSeconds();
  if (ii>=86400000)//1 day
  { if (ttype==5) ;//You can add your own date format here
    if (ttype==4) return(Weekday[ww]);
    if (ttype==3) return(mm+"/"+dd);
    return(dd+"."+mm+".");
  }
  if (ii>=21600000)//6 hours 
  { if (hh==0) 
    { if (ttype==5) ;//You can add your own date format here
      if (ttype==4) return(Weekday[ww]);
      if (ttype==3) return(mm+"/"+dd);
      return(dd+"."+mm+".");
    }
    else
    { if (ttype==5) ;//You can add your own date format here
      if (ttype==4) return((hh<=12) ? hh+"am" : hh%12+"pm");
      if (ttype==3) return((hh<=12) ? hh+"am" : hh%12+"pm");
      return(hh+":00");
    }
  }
  if (ii>=60000)//1 min
  { if (nn<10) nn="0"+nn;
    if (ttype==5) ;//You can add your own date format here
    if (ttype==4) return((hh<=12) ? hh+"."+nn+"am" : hh%12+"."+nn+"pm");
    if (nn=="00") nn="";
    else nn=":"+nn;
    if (ttype==3) return((hh<=12) ? hh+nn+"am" : hh%12+nn+"pm");
    if (nn=="") nn=":00";
    return(hh+nn);
  }
  if (ss<10) ss="0"+ss;
  return(nn+":"+ss);
}
function _Draw(theDrawColor, theTextColor, isScaleText, theTooltipText, theAction)
{ var x0,y0,i,j,itext,l,x,y,r,dx,dy,xr,yr,invdifx,invdify,deltax,deltay,id=this.ID,lay=0,selObj="",divtext="",ii=0;
  var ds=_linux*(2-3*_opera);
  var c151=(_linux && _opera) ? "--" : "&#151;";
  if (_nav4) { lay++; if (document.layers[id]) lay++; }
  else 
  { lay--; 
    if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    if (selObj) lay--;
  }
  if (lay>0)
  { selObj=_nvl(theAction,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    var drawCol=(_nvl(theDrawColor,"")=="") ? "" : "bgcolor="+theDrawColor;
    if (lay>1)
    { with(document.layers[id])
      { top=this.top;
        left=this.left;
        document.open();
        document.writeln("<div style='position:absolute; left:1; top:1;'><table border=1 bordercolor="+theTextColor+" cellpadding=0 cellspacing=0><tr><td "+drawCol+"><a"+selObj+"><img src='transparent.gif' width="+eval(this.right-this.left-1)+" height="+eval(this.bottom-this.top-2)+" border=0></a></td></tr></table></div>");
      }
    }
    else
    { document.writeln("<layer id='"+this.ID+"' top="+this.top+" left="+this.left+" z-Index="+this.zIndex+">"); 
      document.writeln("<div style='position:absolute; left:1; top:1;'><table border=1 bordercolor="+theTextColor+" cellpadding=0 cellspacing=0><tr><td "+drawCol+"><a"+selObj+"><img src='transparent.gif' width="+eval(this.right-this.left-1)+" height="+eval(this.bottom-this.top-2)+" border=0></a></td></tr></table></div>");
    }
  }
  else
  { if (lay<-1)
      selObj.title=_nvl(theTooltipText,"");
    else
      document.writeln("<div id='"+this.ID+"' title='"+_nvl(theTooltipText,"")+"'>"); 
    divtext="<div id='"+this.ID+"i"+eval(ii++)+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute; left:"+eval(this.left)+"; width:"+eval(this.right-this.left+_dSize)+"; top:"+eval(this.top)+"; height:"+eval(this.bottom-this.top+_dSize)+"; background-color:"+theDrawColor+"; color:"+theTextColor+"; border-style:solid; border-width:1; z-index:"+this.zIndex+"'>&nbsp;</div>";
  }
  if (this.XScale==1)
  { dx=(this.xmax-this.xmin);
    if (Math.abs(dx)>0)
    { invdifx=(this.right-this.left)/(this.xmax-this.xmin);
      r=1;
      while (Math.abs(dx)>=100) { dx/=10; r*=10; }
      while (Math.abs(dx)<10) { dx*=10; r/=10; }
      if (Math.abs(dx)>=50) deltax=10*r*_sign(dx);
      else
      { if (Math.abs(dx)>=20) deltax=5*r*_sign(dx);
        else deltax=2*r*_sign(dx);
      }
      x=Math.floor(this.xmin/deltax)*deltax;
      itext=0;
      for (j=12; j>=-1; j--)
      { xr=x+j*deltax;
        x0=Math.round(this.left+(-this.xmin+x+j*deltax)*invdifx);
        if ((x0>=this.left)&&(x0<=this.right))
        { itext++;
          if ((itext!=2)||(!isScaleText))
          { l=String(10*Math.round(xr/r)*r/10);
            if (l.charAt(0)==".") l="0"+l;
            if (l.substr(0,2)=="-.") l="-0"+l.substr(1,100);
          }
          else l=this.xtext;
          if (lay>0)
          { if (lay>1)
            { with(document.layers[id])
                document.writeln("<div style='position:absolute; left:"+eval(x0-50-this.left)+"; top:"+eval(this.bottom-9-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width=102 align=center><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>|<BR>"+l+"</div></td></tr></table></div>");
            }
            else
              document.writeln("<div style='position:absolute; left:"+eval(x0-50-this.left)+"; top:"+eval(this.bottom-9-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width=102 align=center><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>|<BR>"+l+"</div></td></tr></table></div>");
          }
          else
            divtext+="<div id='"+this.ID+"i"+eval(ii++)+"' align=center style='position:absolute; left:"+eval(x0-50+_opera)+"; width:102; top:"+eval(this.bottom-9+_opera)+"; color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal; z-index:"+this.zIndex+"'>|<BR>"+l+"</div>"
        }
      }
    }
  }
  if (this.XScale>1)
  { dx=(this.xmax-this.xmin);
    if (Math.abs(dx)>0)
    { invdifx=(this.right-this.left)/(this.xmax-this.xmin);
      deltax=_DateInterval(Math.abs(dx))*_sign(dx);
      x=Math.floor(this.xmin/deltax)*deltax;
      itext=0;
      for (j=13; j>=-2; j--)
      { xr=x+j*deltax;
        x0=Math.round(this.left+(-this.xmin+x+j*deltax)*invdifx);
        if ((x0>=this.left)&&(x0<=this.right))
        { itext++;
          if ((itext!=2)||(!isScaleText)) l=_DateFormat(xr, Math.abs(deltax), this.XScale);
          else l=this.xtext;
          if (lay>0)
          { if (lay>1)
            { with(document.layers[id])
                document.writeln("<div style='position:absolute; left:"+eval(x0-50-this.left)+"; top:"+eval(this.bottom-9-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width=102 align=center><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>|<BR>"+l+"</div></td></tr></table></div>");
            }
            else
              document.writeln("<div style='position:absolute; left:"+eval(x0-50-this.left)+"; top:"+eval(this.bottom-9-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width=102 align=center><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>|<BR>"+l+"</div></td></tr></table></div>");
          }
          else
            divtext+="<div id='"+this.ID+"i"+eval(ii++)+"' align=center style='position:absolute; left:"+eval(x0-50+_opera)+"; width:102; top:"+eval(this.bottom-9+_opera)+"; color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal; z-index:"+this.zIndex+"'>|<BR>"+l+"</div>"
        }
      }
    }
  }
  if (this.YScale==1)
  { dy=this.ymax-this.ymin;
    if (Math.abs(dy)>0)
    { invdify=(this.bottom-this.top)/(this.ymax-this.ymin);
      r=1;
      while (Math.abs(dy)>=100) { dy/=10; r*=10; }
      while (Math.abs(dy)<10) { dy*=10; r/=10; }
      if (Math.abs(dy)>=50) deltay=10*r*_sign(dy);
      else
      { if (Math.abs(dy)>=20) deltay=5*r*_sign(dy);
        else deltay=2*r*_sign(dy);
      }
      y=Math.floor(this.ymax/deltay)*deltay;
      itext=0;
      for (j=-1; j<=12; j++)
      { yr=y-j*deltay;
        y0=Math.round(this.top+(this.ymax-y+j*deltay)*invdify);
        if ((y0>=this.top)&&(y0<=this.bottom))
        { itext++;
          if ((itext!=2)||(!isScaleText))
          { l=String(Math.round(10*yr/r)*r/10);
            if (l.charAt(0)==".") l="0"+l;
            if (l.substr(0,2)=="-.") l="-0"+l.substr(1,100);
          }
          else l=this.ytext;
          if (lay>0)
          { if (lay>1)
            { with(document.layers[id])
                document.writeln("<div style='position:absolute; left:-100; top:"+eval(y0-8-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(107-ds)+" align=right><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+l+" "+c151+"</div></td></tr></table></div>");
            }
            else
              document.writeln("<div style='position:absolute; left:-100; top:"+eval(y0-8-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(107-ds)+" align=right><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+l+" "+c151+"</div></td></tr></table></div>");
          }
          else
            divtext+="<div id='"+this.ID+"i"+eval(ii++)+"' align=right style='position:absolute; left:"+eval(this.left-100+_opera)+"; width:"+eval(107-ds)+"; top:"+eval(y0-8+_opera)+"; color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal; z-index:"+this.zIndex+"'>"+l+" "+c151+"</div>"
        }
      }
    }
  }
  if (this.YScale>1)
  { dy=this.ymax-this.ymin;
    if (Math.abs(dy)>0)
    { invdify=(this.bottom-this.top)/(this.ymax-this.ymin);
      deltay=_DateInterval(Math.abs(dy))*_sign(dy);
      y=Math.floor(this.ymax/deltay)*deltay;
      itext=0;
      for (j=-2; j<=13; j++)
      { yr=y-j*deltay;
        y0=Math.round(this.top+(this.ymax-y+j*deltay)*invdify);
        if ((y0>=this.top)&&(y0<=this.bottom))
        { itext++;
          if ((itext!=2)||(!isScaleText)) l=_DateFormat(yr, Math.abs(deltay), this.YScale);
          else l=this.ytext;
          if (lay>0)
          { if (lay>1)
            { with(document.layers[id])
                document.writeln("<div style='position:absolute; left:-100; top:"+eval(y0-8-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(107-ds)+" align=right><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+l+" "+c151+"</div></td></tr></table></div>");
            }
            else
              document.writeln("<div style='position:absolute; left:-100; top:"+eval(y0-8-this.top)+";'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(107-ds)+" align=right><div style='color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+l+" "+c151+"</div></td></tr></table></div>");
          }
          else
            divtext+="<div id='"+this.ID+"i"+eval(ii++)+"' align=right style='position:absolute; left:"+eval(this.left-100+_opera)+"; width:"+eval(107-ds)+"; top:"+eval(y0-8+_opera)+"; color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal; z-index:"+this.zIndex+"'>"+l+" "+c151+"</div>"
        }
      }
    }
  }
  if (lay>0)
  { if (lay>1)
    { with(document.layers[id])
      { document.writeln("<div style='position:absolute; left:0; top:-20;'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(this.right-this.left)+" align=center><div style=' color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+this.title+"</div></td></tr></table></div>");
        document.close();
      }
    }
    else
    { document.writeln("<div style='position:absolute; left:0; top:-20;'><table noborder cellpadding=0 cellspacing=0><tr><td width="+eval(this.right-this.left)+" align=center><div style=' color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;'>"+this.title+"</div></td></tr></table></div>");
      document.writeln("</layer>");
    }
  }
  else
  { divtext+="<div id='"+this.ID+"i"+eval(ii++)+"' align=center onClick='"+_nvl(theAction,"")+"' style='position:absolute; left:"+this.left+"; width:"+eval(this.right-this.left)+"; top:"+eval(this.top-20)+"; color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal; z-index:"+this.zIndex+"'>"+this.title+"</div>"
    if (lay<-1)
      selObj.innerHTML=divtext;
    else
      document.writeln(divtext+"</div>");
  }
}

function Bar(theLeft, theTop, theRight, theBottom, theDrawColor, theText, theTextColor, theTooltipText, theAction)
{ this.ID="Bar"+_N_Bar; _N_Bar++; _zIndex++;
  this.left=theLeft;
  this.top=theTop;
  this.width=theRight-theLeft;
  this.height=theBottom-theTop;
  this.DrawColor=theDrawColor;
  this.Text=String(theText);
  this.TextColor=theTextColor;
  this.BorderWidth="";
  this.BorderColor="";
  this.Action=theAction;
  this.SetVisibility=_SetVisibility;
  this.SetText=_SetBarText;
  this.SetTitle=_SetTitle;
  this.MoveTo=_MoveTo;
  this.ResizeTo=_ResizeTo;
  this.Delete=_Delete;
  if (_nav4)
  { var selObj=_nvl(this.Action,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    var tt="";
    while (tt.length<this.Text.length) tt=tt+" ";
    if ((tt=="")||(tt==this.Text)) tt="&nbsp;";
    else tt=this.Text;
    var drawCol=(_nvl(theDrawColor,"")=="") ? "" : "bgcolor="+theDrawColor;
    var textCol=(_nvl(theTextColor,"")=="") ? "" : "color:"+theTextColor+";";
    document.writeln("<layer id='"+this.ID+"' left="+theLeft+" top="+theTop+"; z-Index="+_zIndex+">");
    document.writeln("<layer style='position:absolute;left:0;top:0;'><table noborder cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+eval(theRight-theLeft)+" height="+eval(theBottom-theTop)+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
    document.writeln("</layer>");
  }
  else
  { if (_nvl(theText,"")!="") document.writeln("<div id='"+this.ID+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute;left:"+theLeft+";top:"+theTop+";width:"+eval(theRight-theLeft)+";height:"+eval(theBottom-theTop)+";background-color:"+theDrawColor+";color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:bold;z-index:"+_zIndex+"'; title='"+_nvl(theTooltipText,"")+"' align=center>"+theText+"</div>");
    else document.writeln("<div id='"+this.ID+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute;left:"+theLeft+";top:"+theTop+";width:"+eval(theRight-theLeft)+";height:"+eval(theBottom-theTop)+";background-color:"+theDrawColor+";font-size:1pt;line-height:1pt;font-family:Verdana;font-weight:bold;z-index:"+_zIndex+"'; title='"+_nvl(theTooltipText,"")+"'>&nbsp;</div>");
  }
  return(this);
}
function Box(theLeft, theTop, theRight, theBottom, theDrawColor, theText, theTextColor, theBorderWidth, theBorderColor, theTooltipText, theAction)
{ this.ID="Box"+_N_Box; _N_Box++; _zIndex++;
  this.left=theLeft;
  this.top=theTop;
  this.width=theRight-theLeft;
  this.height=theBottom-theTop;
  this.DrawColor=theDrawColor;
  this.Text=String(theText);
  this.TextColor=theTextColor;
  this.BorderWidth=theBorderWidth;
  this.BorderColor=theBorderColor;
  this.Action=theAction;
  this.SetVisibility=_SetVisibility;
  this.SetText=_SetBarText;
  this.SetTitle=_SetTitle;
  this.MoveTo=_MoveTo;
  this.ResizeTo=_ResizeTo;
  this.Delete=_Delete;
  var bb="";
  var ww=theBorderWidth;
  if (_nvl(theBorderWidth,"")=="") ww=0;
  if (_nav4)
  { if ((_nvl(theBorderWidth,"")!="")&&(_nvl(theBorderColor,"")!=""))
      bb="bordercolor="+theBorderColor;
    var selObj=_nvl(this.Action,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    var tt="";
    while (tt.length<this.Text.length) tt=tt+" ";
    if ((tt=="")||(tt==this.Text)) tt="&nbsp;";
    else tt=this.Text;
    var drawCol=(_nvl(theDrawColor,"")=="") ? "" : "bgcolor="+theDrawColor;
    var textCol=(_nvl(theTextColor,"")=="") ? "" : "color:"+theTextColor+";";
    document.writeln("<layer id='"+this.ID+"' left="+theLeft+" top="+theTop+"; z-Index="+_zIndex+">");
    document.writeln("<layer style='position:absolute;left:"+ww+";top:"+ww+";'><table border="+ww+" "+bb+" cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+eval(theRight-theLeft-ww)+" height="+eval(theBottom-theTop-ww)+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
    document.writeln("</layer>");
  }
  else
  { if ((_nvl(theBorderWidth,"")!="")&&(_nvl(theBorderColor,"")!=""))
      bb="border-style:solid;border-width:"+theBorderWidth+";border-color:"+theBorderColor+";";
    if (_nvl(theText,"")!="")
         document.writeln("<div id='"+this.ID+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute;left:"+theLeft+";top:"+theTop+";width:"+eval(theRight-theLeft+ww*_dSize)+";height:"+eval(theBottom-theTop+ww*_dSize)+";"+bb+"background-color:"+theDrawColor+";color:"+theTextColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:bold;z-index:"+_zIndex+"'; title='"+_nvl(theTooltipText,"")+"' align=center>"+theText+"</div>");
    else document.writeln("<div id='"+this.ID+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute;left:"+theLeft+";top:"+theTop+";width:"+eval(theRight-theLeft+ww*_dSize)+";height:"+eval(theBottom-theTop+ww*_dSize)+";"+bb+"background-color:"+theDrawColor+";font-size:1pt;line-height:1pt;font-family:Verdana;font-weight:bold;z-index:"+_zIndex+"'; title='"+_nvl(theTooltipText,"")+"'>&nbsp;</div>");
  }
  return(this);
}
function _SetBarText(theText)
{ var id=this.ID, selObj;
  this.Text=String(theText);
  if (_nav4)
  { var ww=this.BorderWidth;
    if (_nvl(this.BorderWidth,"")=="") ww=0;
    var selObj=_nvl(this.Action,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    var tt="";
    while (tt.length<this.Text.length) tt=tt+" ";
    if ((tt=="")||(this.Text==tt)) tt="&nbsp;";
    else tt=this.Text;
    var drawCol=(_nvl(this.DrawColor,"")=="") ? "" : "bgcolor="+this.DrawColor;
    var textCol=(_nvl(this.TextColor,"")=="") ? "" : "color:"+this.TextColor+";";
    with(document.layers[id])
    { document.open();
      if ((_nvl(this.BorderWidth,"")!="")&&(_nvl(this.BorderColor,"")!=""))
        document.writeln("<layer style='position:absolute;left:"+ww+";top:"+ww+";'><table border="+ww+" bordercolor="+this.BorderColor+" cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+eval(this.width-ww)+" height="+eval(this.height-ww)+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
      else
        document.writeln("<layer style='position:absolute;left:0;top:0;'><table noborder cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+this.width+" height="+this.height+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
      document.close();
    }
  }
  else
  { if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    selObj.innerHTML=theText;
  }
}
function Dot(theX, theY, theSize, theType, theColor, theTooltipText, theAction)
{ //Symbol=new Array("9632", "9633", "9679", "9675", "120", "9674", "9660", "9650");
  Symbol=new Array("149", "176", "42", "164", "215", "43");
  if (_linux && (_opera || _nav4)) Symbol[0]="35";
  this.Size=theSize;
  if (_linux && _nav4) this.Size=6;
  this.dX=1+this.Size-_opera-Math.floor(_linux*this.Size/4);
  if ((theType%6)<3) this.dX-=Math.floor(this.Size/4)+2;
  if ((theType%6)==3) this.dX-=Math.floor(this.Size/4)+1;
  this.dY=this.Size-1-Math.floor(_opera*this.Size/4);
  if (((theType%6)!=1)&&((theType%6)!=2)) this.dY+=Math.floor(this.Size/2)+1;
  this.ID="Dot"+_N_Dot; _N_Dot++; _zIndex++;
  this.X=theX;
  this.Y=theY;
  this.Type=theType;
  this.Color=theColor;
  this.SetVisibility=_SetVisibility;
  this.SetTitle=_SetTitle;
  this.MoveTo=_DotMoveTo;
  this.Delete=_Delete;
  if (_nav4)
  { var selObj=_nvl(theAction,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    this.dX-=2;
    this.dY-=eval(5-Math.floor(this.Size/2));
    document.writeln("<layer id='"+this.ID+"' left="+eval(theX-this.dX)+" top="+eval(theY-this.dY)+"; z-Index="+_zIndex+">");
    document.writeln("<a style='color:"+theColor+";font-size:"+eval(2*this.Size)+"pt;line-height:"+eval(2*this.Size)+"pt;font-family:Verdana;font-weight:normal;'"+selObj+">&#"+Symbol[theType%6]+";</a>");
    document.writeln("</layer>");
  }
  else
    document.writeln("<div id='"+this.ID+"' onClick='"+_nvl(theAction,"")+"' style='position:absolute;left:"+eval(theX-this.dX)+";top:"+eval(theY-this.dY)+";width:"+eval(2*this.Size)+";height:"+eval(2*this.Size)+";color:"+theColor+";font-size:"+eval(2*this.Size)+"pt;line-height:"+eval(2*this.Size)+"pt;font-family:Verdana;font-weight:normal;z-index:"+_zIndex+"' title='"+_nvl(theTooltipText,"")+"'>&#"+Symbol[theType%6]+";</div>");
  return(this);
}
function _DotMoveTo(theX, theY)
{ var id=this.ID, selObj;
  if (theX!="") this.X=theX;
  if (theY!="") this.Y=theY;
  if (_nav4)
  { with(document.layers[id])
    { if (theX!="") left=eval(theX-this.dX);
      if (theY!="") top=eval(theY-this.dY);
      visibility="show";
    }
  }
  else
  { if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    with (selObj.style)
    { if (theX!="") left=eval(theX-this.dX);
      if (theY!="") top=eval(theY-this.dY);
      visibility="visible";
    }
  }
}
function Pixel(theX, theY, theColor)
{ this.ID="Pix"+_N_Pix; _N_Pix++; _zIndex++;
  this.left=theX;
  this.top=theY;
  this.dX=2-_opera;
  this.dY=11-_opera;
  this.Color=theColor;
  this.SetVisibility=_SetVisibility;
  this.MoveTo=_DotMoveTo;
  this.Delete=_Delete;
  if (_nav4)
  { document.writeln("<layer id='"+this.ID+"' left="+eval(theX-this.dX)+" top="+eval(theY-this.dY)+"; z-Index="+_zIndex+">");
    document.writeln("<div style='position:absolute;left:1;top:2;color:"+theColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:bold;'>.</div>");
    document.writeln("</layer>");
  }
  else
    document.writeln("<div id='"+this.ID+"' style='position:absolute;left:"+eval(theX-this.dX)+";top:"+eval(theY-this.dY)+";color:"+theColor+";font-size:10pt;line-height:12pt;font-family:Verdana;font-weight:normal;z-index:"+_zIndex+"'>.</div>");
  return(this);
}
function _SetVisibility(isVisible)
{ var ll, id=this.ID, selObj;
  if (_nav4)
  { with(document.layers[id])
    { if (isVisible) visibility="show";
      else visibility="hide";
    }
  }
  else
  { if (document.all)
    { selObj=eval("document.all."+id);
      if (isVisible) selObj.style.visibility="visible";
      else selObj.style.visibility="hidden";
    }
    else
    { selObj=document.getElementById(id);
      if (isVisible) selObj.style.visibility="visible";
      else selObj.style.visibility="hidden";
      if (id.substr(0,3)=='Dia')
      { var ii=0;
        selObj=document.getElementById(id+'i'+eval(ii++));
        while (selObj!=null)
        { if (isVisible) selObj.style.visibility="visible";
          else selObj.style.visibility="hidden";
          selObj=document.getElementById(id+'i'+eval(ii++));
        }
      }
    }
  }
}
function _SetTitle(theTitle)
{ var id=this.ID, selObj;
  if (_nav4) return;
  else
  { if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    selObj.title=theTitle;
  }
}
function _MoveTo(theLeft, theTop)
{ var id=this.ID, selObj;
  if (theLeft!="") this.left=theLeft;
  if (theTop!="") this.top=theTop;
  if (_nav4)
  { with(document.layers[id])
    { if (theLeft!="") left=theLeft;
      if (theTop!="") top=theTop;
      visibility="show";
    }
  }
  else
  { if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    with (selObj.style)
    { if (theLeft!="") left=theLeft;
      if (theTop!="") top=theTop;
      visibility="visible";
    }
  }
}
function _ResizeTo(theLeft, theTop, theWidth, theHeight)
{ var id=this.ID, selObj;
  if (theLeft!="") this.left=theLeft;
  if (theTop!="") this.top=theTop;
  if (theWidth!="") this.width=theWidth;
  if (theHeight!="") this.height=theHeight;
  if (_nav4)
  { var ww=this.BorderWidth;
    if (_nvl(this.BorderWidth,"")=="") ww=0;
    var selObj=_nvl(this.Action,"");
    if (selObj!="") selObj=" href='javascript:"+selObj+"'";
    var tt="";
    while (tt.length<this.Text.length) tt=tt+" ";
    if ((tt=="")||(tt==this.Text)) tt="&nbsp;";
    else tt=this.Text;
    var drawCol=(_nvl(this.DrawColor,"")=="") ? "" : "bgcolor="+this.DrawColor;
    var textCol=(_nvl(this.TextColor,"")=="") ? "" : "color:"+this.TextColor+";";
    with(document.layers[id])
    { top=this.top;
      left=this.left;
      document.open();
      if ((_nvl(this.BorderWidth,"")!="")&&(_nvl(this.BorderColor,"")!=""))
        document.writeln("<layer style='position:absolute;left:"+ww+";top:"+ww+";'><table border="+ww+" bordercolor="+this.BorderColor+" cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+eval(this.width-ww)+" height="+eval(this.height-ww)+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
      else
        document.writeln("<layer style='position:absolute;left:0;top:0;'><table noborder cellpadding=0 cellspacing=0><tr><td "+drawCol+" width="+this.width+" height="+this.height+" align=center valign=top><a style='"+textCol+"font-size:10pt;line-height:12pt;font-family:Verdana;text-decoration:none;font-weight:bold;'"+selObj+">"+tt+"</a></td></tr></table></layer>");
      document.close(); 
    }
  }
  else
  { if (document.all) selObj=eval("document.all."+id);
    else selObj=document.getElementById(id);
    with (selObj.style)
    { if (theLeft!="") left=theLeft;
      if (theTop!="") top=theTop;
      if (theWidth!="") width=theWidth;
      if (theHeight!="") height=theHeight;
      visibility="visible";
    }
  }
}
function _Delete()
{ var id=this.ID, selObj;
  if (_nav4)
  { with(document.layers[id])
    { document.open();
      document.close();
    }
  }
  else
  { if (document.all)
    { selObj=eval("document.all."+id);
      selObj.outerHTML="";
    }
    else
    { selObj=document.getElementById(id); 
      selObj.parentNode.removeChild(selObj);
    }
  }
}
function _nvl(vv, rr)
{ if (vv==null) return(rr);
  return(String(vv));
}
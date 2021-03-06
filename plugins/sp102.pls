  -- Collect Changes from statspack - Interface for Oracle 10.2
 statspack.STAT_CHANGES
 ( BID , EID
 , DB_ID , INST_NUM
 , PARA
 , LHTR , BFWT
 , TRAN , CHNG
 , UCAL , UROL
 , RSIZ
 , PHYR , PHYRD
 , PHYRDL , PHYRC
 , PHYW , UCOM
 , PRSE , HPRS
 , RECR , GETS
 , SLR
 , RLSR , RENT
 , SRTM , SRTD
 , SRTR , STRN
 , LHR
 , BBC , EBC 
 , BSP , ESP 
 , LB 
 , BS , TWT
 , LOGC , PRSCPU
 , TCPU , EXE
 , PRSELA
 , BSPM , ESPM
 , BFRM , EFRM
 , BLOG , ELOG
 , BOCUR , EOCUR
 , BPGAALLOC , EPGAALLOC
 , BSGAALLOC , ESGAALLOC
 , BNPROCS , ENPROCS
 , TIMSTAT , STATLVL 
 , BNCPU , ENCPU -- OS STAT
 , BPMEM , EPMEM
 , BLOD , ELOD
 , ITIC , BTIC
 , IOTIC , RWTIC
 , UTIC , STIC
 , VMIB , VMOB
 , OSCPUW
 , DBTIM , DBCPU -- TIME MODEL
 , BGELA , BGCPU
 , PRSTELA , SQLEELA
 , CONMELA
 , DMSD , DMFC -- BEGIN RAC
 , DMSI
 , PMRV , PMPT
 , NPMRV , NPMPT
 , DBFR
 , DPMS , DNPMS
 , GLSG , GLAG
 , GLGT
 , GCCRRV , GCCRRT , GCCRFL
 , GCCURV , GCCURT , GCCUFL
 , GCCRSV
 , GCCRBT , GCCRFT
 , GCCRST , GCCUSV
 , GCCUPT , GCCUFT
 , GCCUST
 , MSGSQ , MSGSQT
 , MSGSQK , MSGSQTK
 , MSGRQ , MSGRQT -- END RAC
 );

  CALL := UCAL + RECR;

  -- Collect Changes from statspack - Interface for Oracle 9.0
  statspack.stat_changes (
   BID, EID,
   DBID, INST_NUM,
   PARA,           -- End of IN arguments
   LHTR, BFWT,
   TRAN, CHNG,
   UCAL, UROL,
   RSIZ,
   PHYR, PHYRD,
   PHYRDL,
   PHYW, UCOM,
   PRSE, HPRS,
   RECR, GETS,
   RLSR, RENT,
   SRTM, SRTD,
   SRTR, STRN,
   LHR, BC,
   SP, LB,
   BS, TWT,
   LOGC, PRSCPU,
   TCPU, EXE,
   PRSELA,
   BSPM, ESPM,
   BFRM, EFRM,
   BLOG, ELOG,
   BOCUR, EOCUR,
   DMSD, DMFC,   -- Begin of RAC
   DFCMS, DFCMR,
   DMSI,
   DMRV, DYNAL,
   DYNARES,
   PMRV, PMPT,
   NPMRV, NPMPT,
   SCMA, SCML,
   PINC, PINCRNC,
   PICC, PICRRC,
   PBC, PBCRC,
   PCBA, PCCRBA,
   PCRBPI,
   DYNAPRES, DYNAPSHL,
   PRCMA, PRCML,
   PWRM, PFPIM,
   PWNM,
   DPMS, DNPMS,
   GLSG, GLAG,
   GLGT, GLSC,
   GLAC, GLCT,
   GLRL,
   GCGE, GCGT,
   GCCV, GCCT,
   GCCRRV, GCCRRT,
   GCCURV, GCCURT,
   GCCRSV,
   GCCRBT, GCCRFT,
   GCCRST, GCCUSV,
   GCCUPT, GCCUFT,
   GCCUST
  );
  CALL := UCAL + RECR;


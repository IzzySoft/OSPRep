  -- Collect Changes from statspack - Interface for Oracle 9.2
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
--   DFCMS, DFCMR, -- removed with v9.2
   DMSI,
--   DMRV, DYNAL,  -- removed with v9.2
--   DYNARES,      -- dito
   PMRV, PMPT,
   NPMRV, NPMPT,
--   SCMA, SCML,   -- removed with v9.2
--   PINC, PINCRNC,-- dito
--   PICC, PICRRC, -- dito
--   PBC, PBCRC,   -- dito
--   PCBA, PCCRBA, -- dito
--   PCRBPI,       -- dito
--   DYNAPRES, DYNAPSHL, -- dito
--   PRCMA, PRCML, -- dito
--   PWRM, PFPIM,  -- dito
--   PWNM,         -- dito
   DBFR,       -- needed since v9.2
   DPMS, DNPMS,
   GLSG, GLAG,
   GLGT, GLSC,
   GLAC, GLCT,
   GLRL,
   GCDFR,      -- needed since v9.2
   GCGE, GCGT,
   GCCV, GCCT,
   GCCRRV, GCCRRT,
   GCCURV, GCCURT,
   GCCRSV,
   GCCRBT, GCCRFT,
   GCCRST, GCCUSV,
   GCCUPT, GCCUFT,
   GCCUST
 ,  MSGSQ, MSGSQT,   -- needed since v9.2
   MSGSQK, MSGSQTK, -- dito
   MSGRQ, MSGRQT    -- dito
  );
  CALL := UCAL + RECR;


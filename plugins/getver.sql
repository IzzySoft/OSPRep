SELECT SUBSTR(version,1,INSTR(version,'.')-1)||
       SUBSTR(version,INSTR(version,'.')+1,INSTR(version,'.',1,2)-1
       - INSTR(version,'.')) ver
  FROM v$instance;

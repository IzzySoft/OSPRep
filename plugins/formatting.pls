  FUNCTION format_fsize(fs IN OUT NUMBER) RETURN VARCHAR2 IS
    string VARCHAR2(50); signed NUMBER;
    BEGIN
      IF fs IS NULL THEN
        RETURN '&nbsp;';
      END IF;
      IF fs < 0 THEN
        signed := 1;
	fs := (-1) * fs;
      ELSE
        signed := 0;
      END IF;
      IF fs/1024 > 999 THEN
        IF fs/1024/1024 > 999 THEN
          IF fs/1024/1024/1024 > 999 THEN
            string := to_char(round(fs/1024/1024/1024/1024,1),'990.0')||' T';
          ELSE
            string := to_char(round(fs/1024/1024/1024,1),'990.0')||' G';
          END IF;
        ELSE
          string := to_char(round(fs/1024/1024,1),'990.0')||' M';
        END IF;
      ELSE
        string := to_char(round(fs/1024,1),'990.0')||' K';
      END IF;
      IF signed = 1 THEN
        string := '- '||string;
      END IF;
      RETURN string;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLERRM;
    END;

  FUNCTION format_stime(st IN OUT NUMBER,sdiv IN NUMBER) RETURN VARCHAR2 IS
    string VARCHAR2(50); mt NUMBER; signed NUMBER;
    BEGIN
      IF st IS NULL THEN
        RETURN '&nbsp;';
      ELSIF st < 0 THEN
        signed := 1;
	st := (-1) * st;
      ELSE
        signed := 0;
      END IF;
      IF sdiv = 10 THEN
        string := '.'||trim(to_char(mod(st,sdiv),'0'));
      ELSIF sdiv = 100 THEN
        string := '.'||trim(to_char(mod(st,sdiv),'00'));
      ELSIF sdiv = 1000 THEN
        string := '.'||trim(to_char(mod(st,sdiv),'000'));
      ELSE
        string := '';
      END IF;
      mt := round(st/sdiv);
      IF (round(mt/60) > 0) OR (mod(mt,60) > 9) THEN
        string := trim(to_char(mod(mt,60),'00'))||string; -- s
      ELSE
        string := trim(to_char(mod(mt,60),'0'))||string;
      END IF;
      mt := round(mt/60);
      IF mt > 0 THEN
        IF (round(mt/60) > 0) OR (mod(mt,60) > 9) THEN
          string := trim(to_char(mod(mt,60),'00'))||':'||string; -- min
        ELSE
          string := trim(to_char(mod(mt,60),'0'))||':'||string;
        END IF;
        mt := round(mt/60);
        IF mt > 0 THEN
          string := trim(to_char(mod(mt,24),'90'))||':'||string; -- h
          mt := round(mt/24);
          IF mt > 365 THEN
            string := round(mt/365)||'y '||to_char(mod(mt,365))||'d '||string;
          ELSIF mt > 1 THEN
            string := mt||'d '||string;
          END IF;
        END IF;
      END IF;
      IF signed = 1 THEN
        string := '- '||string;
      END IF;
      RETURN string;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLERRM;
    END;

  FUNCTION numformat (val IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
      RETURN to_char(val,'9,999,999,990');
    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
    END;

  FUNCTION decformat (val IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
      RETURN to_char(round(val,2),'9,999,999,990.00');
    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
    END;

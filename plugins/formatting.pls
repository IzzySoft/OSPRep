  FUNCTION format_fsize(fs IN NUMBER) RETURN VARCHAR2 IS
    string VARCHAR2(50);
    BEGIN
      IF fs IS NULL THEN
        RETURN '&nbsp;';
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
      RETURN string;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLERRM;
    END;

  FUNCTION format_stime(st IN NUMBER,sdiv IN NUMBER) RETURN VARCHAR2 IS
    string VARCHAR2(50); mt NUMBER;
    BEGIN
      IF st IS NULL THEN
        RETURN '&nbsp;';
      END IF;
      CASE sdiv
        WHEN   10 THEN string := '.'||trim(to_char(mod(st,sdiv),'0'));
        WHEN  100 THEN string := '.'||trim(to_char(mod(st,sdiv),'00'));
        WHEN 1000 THEN string := '.'||trim(to_char(mod(st,sdiv),'000'));
        ELSE string := '';
      END CASE;
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
            RETURN round(mt/365)||'y '||to_char(mod(mt,365))||'d '||string;
          ELSIF mt > 1 THEN
            RETURN mt||'d '||string;
          END IF;
        END IF;
      END IF;
      RETURN string;
    EXCEPTION
      WHEN OTHERS THEN RETURN SQLERRM;
    END;


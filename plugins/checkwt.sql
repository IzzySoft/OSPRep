DECLARE
 temp_count NUMBER; statement VARCHAR2(255);
BEGIN
  statement := 'SELECT COUNT(*) FROM istats$waitobjects';
  EXECUTE IMMEDIATE statement INTO temp_count;
  IF temp_count = 0
  THEN
    dbms_output.put_line('0');
  ELSE
    dbms_output.put_line('1');
  END IF;
EXCEPTION
  WHEN OTHERS THEN dbms_output.put_line('0');
END;
/


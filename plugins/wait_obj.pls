  -- Wait Objects
  S1 := 'istats$waitobjects'; I1 := 1; I2 := 0;
  tab_exists(S1,I1,I2);
  IF I2 = 1
  THEN
    get_waitobj;
  END IF;


  CURSOR C_RLim IS
    SELECT resource_name rname,
           to_char(current_utilization,'999,999,990') curu,
           to_char(max_utilization,'999,999,990') maxu,
           to_char(initial_allocation,'999,999,990') inita,
           to_char(limit_value,'999,999,990') lim,
           current_utilization curnum,
           max_utilization maxnum,
           limit_value limnum
      FROM stats$resource_limit
     WHERE snap_id = EID
       AND dbid    = DB_ID
       AND instance_number = INST_NUM
     ORDER BY rname;

  CURSOR C_RLim IS
    SELECT resource_name rname,
           to_char(current_utilization,'999,999,990') curu,
           to_char(max_utilization,'999,999,990') maxu,
           to_char(initial_allocation,'999,999,990') inita,
           to_char(limit_value,'999,999,990') lim
      FROM stats$resource_limit
     WHERE snap_id = EID
       AND dbid    = DB_ID
       AND instance_number = INST_NUM
       AND (   nvl(current_utilization,0)/limit_value > .8
            or nvl(max_utilization,0)/limit_value > .8 )
     ORDER BY rname;

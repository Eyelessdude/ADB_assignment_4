SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime6(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
IS
start_time FLOAT;
end_time FLOAT;
resulted_time FLOAT;
iterationsAmount integer := 10;
localMax FLOAT := 0;
localMin FLOAT := 1000000;
localAvg FLOAT := 0;


BEGIN

FOR loopCounter IN 1..10 LOOP
    ROLLBACK;
    EXECUTE IMMEDIATE 'ALTER SYSTEM FLUSH BUFFER_CACHE';
    EXECUTE IMMEDIATE 'ALTER SYSTEM FLUSH SHARED_POOL';
    
    start_time := dbms_utility.get_time;
    dbms_output.put_line('Start: ' || start_time); 
    
    DELETE FROM review rev 
    WHERE rev.clientid IN (
        SELECT cli.clientid FROM Client cli
        JOIN "Order" ord ON ord.clientid = cli.clientid WHERE (ord.orderdate < '19.11.2020  00:00:00')
    )
    OR rev.reviewdate < '19.11.2020 00:00:00';
    
    end_time := dbms_utility.get_time;
    dbms_output.put_line('End: ' || end_time); 
    
    resulted_time := (end_time - start_time) / 100;
    
    dbms_output.put_line('Resulted: ' || resulted_time); 
    
    localAvg := (localAvg + resulted_time); 
    
    IF resulted_time > localMax THEN
        localMax := resulted_time;
        maxTime := localMax;
    END IF;
    
    IF resulted_time < localMin THEN
        localMin := resulted_time;
        minTime := localMin;
    END IF;
END LOOP;
    avgTime := localAvg / iterationsAmount;
    ROLLBACK;
END;
/
show errors


DECLARE
minTime FLOAT := 0;
maxTime FLOAT := 0;
avgTime FLOAT := 0;
queryCursor SYS_REFCURSOR;

BEGIN
measureexecutiontime6(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('sixth_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
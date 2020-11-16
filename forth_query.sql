SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime4(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
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
    
    UPDATE Address adr
    SET adr.city = 'Czechowice-Dziedzice', adr.postalcode = 69696, adr.state='Poland'
    WHERE adr.addressId IN (
        SELECT adr.addressId FROM Address adr WHERE adr.city LIKE '%Port%'
        OR adr.line1 LIKE '%Trail%'
    )
    OR adr.clientId IN (
        SELECT client.clientId FROM CLient client JOIN Address adr ON client.clientID = adr.clientId 
        WHERE client.firstname LIKE '%yan%' AND client.firstname NOT LIKE '%ogdan%');
    
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
measureexecutiontime4(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('forth_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
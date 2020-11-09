SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime2(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
IS
start_time FLOAT;
end_time FLOAT;
resulted_time FLOAT;
iterationsAmount integer := 10;
localMax FLOAT := 0;
localMin FLOAT := 1000000;
localAvg FLOAT := 0;

/* Define cursor with query to be executed */
CURSOR cc IS SELECT COUNT(payment.paymentId) FROM Payment payment
JOIN Address paymentAddress ON payment.addressid=paymentAddress.addressid
JOIN (SELECT adr.* FROM Address adr 
        JOIN client cli ON cli.clientId=adr.clientId) clientAddress ON clientAddress.line1=paymentAddress.line1 
        AND clientAddress.line2=paymentAddress.line2
        AND clientAddress.city=paymentAddress.city
        AND clientAddress."STATE"=paymentAddress."STATE"
        AND paymentAddress."STATE" LIKE '%Alabama%'
        AND clientAddress.postalcode=paymentAddress.postalcode
JOIN Client client ON clientAddress.clientId=client.clientId
JOIN "Order" ord ON ord.clientId=client.clientid WHERE ord.total >= 2000
ORDER BY payment.cardtype DESC;


TYPE fetched_table_type IS TABLE OF cc%ROWTYPE;
fetched_table fetched_table_type;

BEGIN
/* Execute one query to eliminate time difference */
OPEN cc;
FETCH cc BULK COLLECT INTO fetched_table;
CLOSE cc;
ROLLBACK;

FOR loopCounter IN 1..10 LOOP
    ROLLBACK;
    EXECUTE IMMEDIATE 'ALTER SYSTEM FLUSH BUFFER_CACHE';
    EXECUTE IMMEDIATE 'ALTER SYSTEM FLUSH SHARED_POOL';
    OPEN cc;
    
    start_time := dbms_utility.get_time;
    dbms_output.put_line('Start: ' || start_time); 
    FETCH cc BULK COLLECT INTO fetched_table;
    end_time := dbms_utility.get_time;
    dbms_output.put_line('End: ' || end_time); 
    CLOSE cc;
    
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
measureexecutiontime2(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('second_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
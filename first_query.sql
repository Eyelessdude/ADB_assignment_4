SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime1(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
IS
start_time FLOAT;
end_time FLOAT;
resulted_time FLOAT;
iterationsAmount integer := 10;
localMax FLOAT := 0;
localMin FLOAT := 1000000;
localAvg FLOAT := 0;

/* Define cursor with query to be executed */
CURSOR cc IS SELECT client.email FROM Client client WHERE client.clientId IN (
        SELECT address.clientId FROM Address address JOIN Payment payment ON address.addressId = payment.addressid
            WHERE payment.cardType NOT LIKE '%JCB%'
            AND (payment.paymentId IN (
                    SELECT payment2.paymentId FROM Payment payment2 WHERE  payment.clientId IN(
                        SELECT client2.clientId FROM Client client2 WHERE client2.clientId IN(
                            SELECT review.clientId FROM Review review 
                                WHERE review.stars NOT IN (0, 1, 2)
                                OR review.reviewdate >= '2019.05.02 00:00:00'
                        )
                        OR client2.email LIKE '%.com%' OR client2.email LIKE '%.biz%' OR client2.email LIKE '%.net%'
                    )
                )
                OR payment.expyear BETWEEN 2019 AND 2025
            )
            GROUP BY address.clientId);

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
measureexecutiontime1(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('first_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
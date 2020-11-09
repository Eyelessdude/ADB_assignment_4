SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime3(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
IS
start_time FLOAT;
end_time FLOAT;
resulted_time FLOAT;
iterationsAmount integer := 10;
localMax FLOAT := 0;
localMin FLOAT := 1000000;
localAvg FLOAT := 0;

/* Define cursor with query to be executed */
CURSOR cc IS SELECT * FROM "Order" ord
    JOIN (SELECT * FROM Product_Order prod_order
            JOIN Product product ON prod_order.productId = product.productId
            JOIN (SELECT * FROM Review rev WHERE rev.stars >= 4) review ON review.productId = product.productId) products ON products.orderId = ord.orderId
    JOIN Payment payment ON payment.paymentid = ord.paymentId WHERE payment.cardType LIKE '%visa%'
    ORDER BY ord.orderId;

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
measureexecutiontime3(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('third_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
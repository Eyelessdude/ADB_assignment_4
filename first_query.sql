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
CURSOR cc IS SELECT ord.* FROM "Order" ord 
                JOIN Client cli ON ord.clientId = cli.clientId
                JOIN Review rev ON cli.clientId = rev.clientId AND rev.stars BETWEEN 0 AND 3
                JOIN product_order prod_order ON ord.orderId = prod_order.orderId
                JOIN (SELECT product.productId, product.title FROM Product product
                        JOIN product_specialoffer prod_offer ON prod_offer.productId = product.productId
                        JOIN SpecialOffer offer ON offer.offerId = prod_offer.specialOfferId
                        WHERE offer.startdate >= '27.02.20 04:51:36' AND offer.enddate <= '17.12.20 00:08:04'
                        GROUP BY product.productid, product.title) prod ON prod.productId = prod_order.productId
                ORDER BY ord.status, ord.total DESC;

TYPE fetched_table_type IS TABLE OF cc%ROWTYPE;
fetched_table fetched_table_type;

BEGIN
/* Execute one query to eliminate time difference */
OPEN cc;
FETCH cc BULK COLLECT INTO fetched_table;
CLOSE cc;

FOR loopCounter IN 1..10 LOOP
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
    
    ROLLBACK;
END LOOP;
    avgTime := localAvg / iterationsAmount;
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

INSERT INTO LOGGER(minTime, maxTime, avgTime) VALUES(minTime, maxTime, avgTime);

END;
/
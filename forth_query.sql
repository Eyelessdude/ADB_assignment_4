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
    
    UPDATE Product prod
    SET prod.price = (prod.price * 1.2)
    WHERE prod.productId IN (
        SELECT DISTINCT product.productId FROM Product product
        JOIN product_order prod_order ON prod_order.productId = product.productId
        JOIN (SELECT ord.* FROM "Order" ord WHERE ord.clientId IN (
            SELECT ord.clientId FROM "Order" ord
            JOIN Client client ON ord.clientId = client.clientId
            JOIN Address address ON client.clientid = address.clientId WHERE address."STATE" LIKE '%Connecticut%'
            GROUP BY ord.clientId
            HAVING COUNT(ord.clientId) >= 5)
        ) ord ON ord.orderId = prod_order.orderId
        WHERE NOT EXISTS(SELECT * FROM product_specialoffer prod_offer WHERE prod_offer.productId = product.productId)
    );
    
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
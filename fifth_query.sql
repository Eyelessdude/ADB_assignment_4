SET serveroutput on;

CREATE OR REPLACE PROCEDURE measureExecutionTime5(executedQuery IN SYS_REFCURSOR, minTime OUT FLOAT, maxTime OUT FLOAT, avgTime OUT FLOAT)
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
    
    UPDATE specialOffer spc
    SET spc.percentdiscount = 20
    WHERE spc.offerid IN (
        SELECT prod_offer.specialofferid FROM product_specialoffer prod_offer
        JOIN Product product ON prod_offer.productid = product.productid
        WHERE (product.price < 500 AND product."size" < 4)
    )
    AND spc.description LIKE '%his%' OR spc.description LIKE '%herss%';
    
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
measureexecutiontime5(queryCursor, minTime, maxTime, avgTime);
dbms_output.put_line('Min: ' || mintime);
dbms_output.put_line('Max: ' || maxtime);
dbms_output.put_line('Average: ' || avgtime); 

INSERT INTO LOGGER(queryName, minTime, maxTime, avgTime) VALUES('fifth_query', minTime, maxTime, avgTime);
COMMIT;

END;
/
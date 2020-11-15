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
            AND payment.paymentId IN (
                SELECT payment2.paymentId FROM Payment payment2 WHERE  payment.clientId IN(
                    SELECT client2.clientId FROM Client client2 WHERE client2.clientId IN(
                        SELECT review.clientId FROM Review review 
                            WHERE review.stars >= 1
                            AND review.reviewdate >= '22.05.2019 00:00:00'
                    )
                    AND client2.email LIKE '%.com%' OR client2.email LIKE '%.biz%' OR client2.email LIKE '%.net%'
                )
            )
            AND payment.expyear >= 2020
            AND address.line2 NOT LIKE '%' || SUBSTR((SELECT payment2.cardNumber FROM Payment payment2 
                                                        GROUP BY payment2.cardNumber ORDER BY COUNT(*) FETCH NEXT 1 ROW ONLY), 3, 4) || '%'
            AND payment.cardType = (
                SELECT payment3.cardType FROM Payment payment3 JOIN "Order" ord ON ord.paymentId = payment3.paymentId
                    WHERE payment3.paymentId = (SELECT ord2.paymentId FROM "Order" ord2 GROUP BY ord2.paymentId ORDER BY COUNT(*) FETCH NEXT 1 ROW ONLY)
                 /*  AND ord.orderId IN (SELECT ord_prod.orderId FROM product_order ord_prod JOIN Product product ON product.productId = ord_prod.productId
                                            WHERE product."size" = '5'
                                            AND product."STYLE" IN ('boots', 'high-heels', 'flats')
                                            AND product.title LIKE '%new%')*/
                    AND ord.clientId IN (SELECT 
                                            client3.clientId FROM Client client3 
                                            WHERE client3.firstName LIKE '%o%' OR client3.firstName LIKE '%e%'
                                            AND client3.lastName LIKE '%s%' OR client3.lastName LIKE '%r%' OR client3.lastName LIKE '%a%')
            )
            GROUP BY address.clientId
    )
    AND client.firstName NOT IN (SELECT client4.firstName FROM Client client4 GROUP BY client4.firstName HAVING COUNT(*) < 2);

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
SELECT COUNT(*) FROM (
    SELECT client.email FROM Client client WHERE client.clientId IN (
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
    AND client.firstName NOT IN (SELECT client4.firstName FROM Client client4 GROUP BY client4.firstName HAVING COUNT(*) < 2)
);

ALTER SYSTEM FLUSH BUFFER_CACHE;
ALTER SYSTEM FLUSH SHARED_POOL;
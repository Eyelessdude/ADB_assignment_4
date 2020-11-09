DROP TABLE LOGGER;

CREATE TABLE LOGGER (
	queryId INT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) NOT NULL PRIMARY KEY,
    queryName VARCHAR(50) NOT NULL,
	minTime FLOAT NOT NULL,
	maxTime FLOAT NOT NULL,
	avgTime FLOAT NOT NULL
);

/* Run all measurement scripts
@first_query.sql
@second_query.sql
*/

SELECT * FROM LOGGER;
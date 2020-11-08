DROP TABLE LOGGER;

CREATE TABLE LOGGER (
	queryId INT NOT NULL GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY,
	minTime INT NOT NULL,
	maxTime INT NOT NULL,
	avgTime INT NOT NULL
);

/* Run all measurement scripts
@first_query.sql
@second_query.sql
*/

SELECT * FROM LOGGER;
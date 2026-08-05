DROP DATABASE IF EXISTS gamedb;
CREATE DATABASE gamedb;
USE gamedb;

DELIMITER \\
DROP PROCEDURE IF EXISTS make_tables\\
CREATE PROCEDURE make_tables ()
BEGIN


	DROP TABLE IF EXISTS tblUser;
    CREATE TABLE tblUser(
		UserName VARCHAR(255) PRIMARY KEY,
        Score INT DEFAULT 10
    );
    
    INSERT INTO tblUser(UserName)
    VALUES ('Todd'),
			('Fred');
END\\
DELIMITER ;

CALL make_tables();

SELECT * FROM tblUser;
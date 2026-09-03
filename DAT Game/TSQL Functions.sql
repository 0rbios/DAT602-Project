USE gamedb;

DROP PROCEDURE IF EXISTS `Login`;
DROP PROCEDURE IF EXISTS `Create_Account`;
DROP PROCEDURE IF EXISTS `Create_Room`;
DROP PROCEDURE IF EXISTS `Layout_Tiles`;

DELIMITER //

-- Player login, including lock out
CREATE PROCEDURE `Login`(
	IN In_Username VARCHAR(32),
	IN In_Password VARCHAR(32)
)
login_process:BEGIN

	-- If the account doesn't exist, try to create it
	IF NOT EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Username) THEN
		CALL `Create_Account`(In_Username, In_Password);
		LEAVE login_process;
	END IF;
    
    -- If the password if wrong, tell the user and increase the account's login attempts
	IF EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Username AND `Password` = In_Password) THEN
		SELECT 'Incorrect Password' AS message;
        
		UPDATE `account`
		SET `LoginAttempts` = `LoginAttempts` + 1
		WHERE EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Username);
        
        LEAVE login_process;
	END IF;
	
    -- If all goes well, return the username and reset the login attempts
	SELECT `AccountName`
	FROM `account`
	WHERE EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Username);
    
    UPDATE `account`
	SET `LoginAttempts` = 0
	WHERE EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Username);
	
END//

-- 2. Player registration
CREATE PROCEDURE `Create_Account` (
	IN IN_Username VARCHAR(32),
	IN IN_Password VARCHAR(32)
)
BEGIN

	IF NOT EXISTS (SELECT * FROM `account` WHERE `AccountName` = IN_Username) THEN
		INSERT INTO `account` (`AccountName`, `Password`)
			VALUES (IN_Username, IN_Password);
		SELECT * FROM `account`;
	ELSE
		SELECT 'Account name already exists' as message;
	END IF;
    
END//

-- Creating a room
CREATE PROCEDURE `Create_Room`(
	IN In_Name VARCHAR(32),
    IN In_Player VARCHAR(32)
)
room_creation:BEGIN
	
    IF NOT EXISTS (SELECT * FROM `account` WHERE `AccountName` = In_Player) THEN
		SELECT 'Invalid Account Name' as message;
        LEAVE room_creation;
	END IF;
    
	INSERT INTO `room` (`RoomName`, `AccountName`)
		VALUES (In_Name, In_Player);
    
END//

-- 3. Laying out tiles on a game board
CREATE PROCEDURE `Layout_Tiles`(
	IN InRoom INT,
	IN mapX INT,
    IN mapY INT
)
create_tiles:BEGIN
    DECLARE tx INT DEFAULT 0;
    DECLARE ty INT DEFAULT 0;
    
    
    IF NOT EXISTS (SELECT * FROM `room` WHERE `RoomID` = INRoom) THEN
		SELECT 'Room Does Not Exist' AS message;
	END IF;
    
    tileX: LOOP
		SET ty = 0;
    
        tileY: LOOP
            INSERT INTO `tile` (`XPos`, `YPos`, `RoomID`)
				VALUES (tx, ty, InRoom);
                
			SET ty = ty + 1;
            
            IF ty < mapY THEN
				ITERATE tileY;
			END IF;
            
			LEAVE tileY;
        END LOOP tileY;
        
		SET tx = tx + 1;
        
		IF tx < mapX THEN
			ITERATE tileX;
		END IF;
        
        LEAVE tileX;
	END LOOP tileX;
    
    SELECT * FROM `tile`;
    
END//

-- 4. Placing an item on a tile


-- 5. Player game play movement


-- 6. Game play scoring


-- 7. Player game play acquiring inventory


-- 8. Move an Item (NPC effect)


-- 9. Kill running games


-- 10. Add new players


-- 11. Update data of a player


-- 12. Delete a player

DELIMITER ;

CALL `Login`('Test Account', 'Test Password');
CALL `Create_Room`('Test Room', 'Test Account');
CALL `Layout_Tiles`(1, 5, 5);
USE gamedb;

DROP PROCEDURE IF EXISTS `Login`;
DROP PROCEDURE IF EXISTS `Create_Account`;
DROP PROCEDURE IF EXISTS `Create_Room`;
DROP PROCEDURE IF EXISTS `Layout_Tiles`;
DROP PROCEDURE IF EXISTS `Place_Ability_On_Tile`;
DROP PROCEDURE IF EXISTS `Create_Ability`;
DROP PROCEDURE IF EXISTS `Create_Player`;
DROP PROCEDURE IF EXISTS `Move_Player`;
DROP PROCEDURE IF EXISTS `Update_Score`;
DROP PROCEDURE IF EXISTS `Get_Leaderboard`;
DROP PROCEDURE IF EXISTS `Pickup_Abiltiy`;
DROP PROCEDURE IF EXISTS `Delete_Account`;
DROP PROCEDURE IF EXISTS `Kill_Room`;
DROP FUNCTION IF EXISTS `Get_Score`;

DELIMITER //

-- Account login, including lock out
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
		WHERE `AccountName` = In_Username;
        
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

-- Account registration
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

-- Laying out tiles on a game board
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

END//

-- Creating abilities
CREATE PROCEDURE `Create_Ability`()
BEGIN
	
    INSERT INTO `ability` (`AbilityName`, `Description`, `Value`, `Cost`, `Combat`, `Sprite`)
		VALUES ('Test Ability', 'This is a test ability', 10, 10, 0, './Test.png');

END//

-- Placing an ability on a tile
CREATE PROCEDURE `Place_Ability_On_Tile`(
	IN InAbility INT,
    IN InTile INT
)
ability_placement:BEGIN

	IF NOT EXISTS (SELECT * FROM `tile` WHERE `TileID` = InTile) THEN
		SELECT 'Tile does not exist' AS message;
        LEAVE ability_placement;
    END IF;
    
	IF NOT EXISTS (SELECT * FROM `ability` WHERE `AbilityID` = InAbility) THEN
		SELECT 'Ability does not exist' AS message;
        LEAVE ability_placement;
    END IF;

	INSERT INTO `Tile_Ability` (`Timestamp`, `TileID`, `AbilityID`)
		VALUES (current_timestamp(), InTile, InAbility);

END//

-- Create player and place on home tile
CREATE PROCEDURE `Create_Player`(
	IN InAccountName VARCHAR(32),
    IN InRoomID INT
)
create_player:BEGIN

	IF NOT EXISTS (SELECT * FROM `account` WHERE `AccountName` = InAccountName) THEN
		SELECT 'Account does not exist' AS message;
        LEAVE create_player;
	END IF;
    
	IF NOT EXISTS (SELECT * FROM `room` WHERE `RoomID` = InRoomID) THEN
		SELECT 'Room does not exist' AS message;
        LEAVE create_player;
	END IF;

	INSERT INTO `player` (`CurrentEnergy`, `CurrentHealth`, `AccountName`, `RoomID`, `Sprite`)
		VALUES (10, 10, InAccountName, InRoomID, './Player.png');

	-- Places the player with the given account and room who also has the largest auto_incementing ID onto the tile with position 0,0 on the given table.
	INSERT INTO `player_tile` (`TileID`, `PlayerID`, `Timestamp`)
		VALUES (
				(SELECT `TileID` FROM `tile` WHERE `RoomID` = InRoomID AND `XPos` = 0 AND `YPos` = 0),
                (SELECT `PlayerID` FROM `player` WHERE `AccountName` = InAccountName AND `RoomID` = InRoomID ORDER BY `PlayerID` LIMIT 1),
                current_timestamp()
				);

END//

-- Find available movement tiles and move player
CREATE PROCEDURE `Move_Player`(
    IN Player INT,
	IN MoveX INT,
    IN MoveY INT,
	IN SearchRadius INT,
    IN AllowDiagonal BIT
)
move_player:BEGIN

	DECLARE playerX INT;
	DECLARE playerY INT;

    IF SearchRadius < 1 THEN
		SELECT 'Search radius too small' AS message;
        LEAVE move_player;
	END IF;
    
	IF NOT EXISTS (SELECT * FROM `player` WHERE `PlayerID` = Player) THEN
		SELECT 'Player not found' AS message;
        LEAVE move_player;
	END IF;
    
    SET playerX = (SELECT `XPos` FROM `tile` WHERE `TileID` = (SELECT `TileID` FROM `player_tile` WHERE `PlayerID` = Player ORDER BY `Timestamp` LIMIT 1));
    SET playerY = (SELECT `YPos` FROM `tile` WHERE `TileID` = (SELECT `TileID` FROM `player_tile` WHERE `PlayerID` = Player ORDER BY `Timestamp` LIMIT 1));

	IF AllowDiagonal = 1 THEN
		-- Checks if the requested position is within the radius around the player
		IF NOT EXISTS (SELECT * FROM (SELECT *
								FROM `tile`
								WHERE `XPos` >= playerX - searchRadius
									AND `XPos` <= playerX + searchRadius
									AND `YPos` >= playerY - searchRadius
									AND `YPos` <= playerY + searchRadius
									AND `RoomID` = (SELECT `RoomID`
													FROM `player`
													WHERE `PlayerID` = Player)) AS Available
			WHERE `XPos` = MoveX AND `YPos` = MoveY) THEN
				SELECT 'Tile out of range' as message;
                LEAVE move_player;
		END IF;
	ELSE
		-- Checks if the requested position is within the bounds the the straights out from the player
		IF NOT EXISTS (SELECT * FROM (SELECT *
										FROM `tile`
										WHERE ((`XPos` >= playerX - searchRadius
												AND `XPos` <= playerX + searchRadius)
												AND `YPos` = playerY)
												OR ((`YPos` >= playerY - searchRadius
												AND `YPos` <= playerY + searchRadius)
												AND `XPos` = playerX)
												AND `RoomID` = (SELECT `RoomID`
																FROM `player`
																WHERE `PlayerID` = Player)) AS Availalable
			WHERE `XPos` = MoveX AND `YPos` = MoveY) THEN
				SELECT 'Tile out of range' as message;
				LEAVE move_player;
		END IF;
	END IF;
	
    INSERT INTO `player_tile` (`TileID`, `PlayerID`, `Timestamp`)
		VALUES ((SELECT `TileID` FROM `tile` WHERE `XPos` = MoveX AND `YPos` = MoveY), Player, current_timestamp());
    
    
    SELECT * FROM `player_tile`;
END//

-- Update score
CREATE PROCEDURE `Update_Score` (
	IN Player INT
)
update_score:BEGIN

	-- Back out if the player id doesn't exist
	IF NOT EXISTS (SELECT * FROM `player` WHERE `PlayerID` = Player) THEN
		SELECT 'Invalid Player ID' AS message;
        LEAVE update_score;
	END IF;

	-- Make sure there is something in the inventory before updating or just make the score 0
    IF NOT EXISTS (SELECT * FROM `player_ability` WHERE `PlayerID` = Player AND `Dropped` IS NULL) THEN
		
		UPDATE `player`
		SET `CurrentScore` = 0
		WHERE `PlayerID` = Player;
	
    ELSE
    
		-- Update the player's score
		UPDATE `player`
		SET `CurrentScore` = (SELECT SUM(a.`Value`) FROM `player_ability` AS pa JOIN `ability` AS a ON pa.`AbilityID` = a.`AbilityID` WHERE pa.`Dropped` IS NULL GROUP BY pa.`PlayerID` HAVING pa.`PlayerID` = 1)
		WHERE `PlayerID` = Player;
    
	END IF;
    
    -- If they have a new highscore, set it
    IF (SELECT `CurrentScore` FROM `player`) > (SELECT `HighScore` FROM `player`) THEN
		UPDATE `player`
        SET `HighScore` = `CurrentScore`
        WHERE `PlayerID` = Player;
	END IF;

END//

-- Get score
CREATE FUNCTION `Get_Score` ( Player INT )
RETURNS INT DETERMINISTIC
BEGIN

	IF NOT EXISTS (SELECT `CurrentScore` FROM `player` WHERE `PlayerID` = Player) THEN
		RETURN 0;
	END IF;

	RETURN (SELECT `CurrentScore` FROM `player` WHERE `PlayerID` = Player);
    
END//

-- Get leaderboard
CREATE PROCEDURE `Get_Leaderboard`(
	IN Room INT
)
get_leaderboard:BEGIN

	IF NOT EXISTS (SELECT * FROM `room` WHERE `RoomID` = Room) THEN
		SELECT 'Invalid Room' AS message;
		LEAVE get_leaderboard;
	END IF;

	SELECT `AccountName`, `HighScore` FROM `player` WHERE `RoomID` = Room;

END//

-- Player acquiring inventory
CREATE PROCEDURE `Pickup_Ability` (
	IN Player INT,
    IN Ability INT
)
ability_pickup:BEGIN

	IF NOT EXISTS (SELECT * FROM `player` WHERE `PlayerID` = Player) THEN
		SELECT 'Invalid player' AS message;
        LEAVE ability_pickup;
	END IF;
    
	IF NOT EXISTS (SELECT * FROM `ability` WHERE `abilityID` = Ability) THEN
		SELECT 'Invalid ability' AS message;
        LEAVE ability_pickup;
	END IF;
    
    INSERT INTO `player_ability` (`PlayerID`, `AbilityID`, `PickedUp`)
		VALUES (Player, Ability, current_timestamp());
    
END//

-- Glitch ability movement


-- Kill running games
CREATE PROCEDURE `Kill_Room`(
	IN Room INT
)
kill_room:BEGIN

	IF NOT EXISTS (SELECT * FROM `room` WHERE `RoomID` = Room) THEN
		SELECT 'Room does not exist' AS message;
        LEAVE kill_room;
	END IF;
    
    DELETE FROM `room` WHERE `RoomID` = Room;

END//

-- Add new account


-- Update data of an account


-- Delete an account
CREATE PROCEDURE `Delete_Account`(
	IN InAccount VARCHAR(32),
    IN Confirm BIT
)
delete_account:BEGIN

	IF Confirm <> 1 THEN
		SELECT 'Account Deletion Cancelled' AS message;
		LEAVE delete_account;
	END IF;
    
    IF NOT EXISTS (SELECT * FROM `account` WHERE `AccountName` = InAccount) THEN
		SELECT 'Account does not exist' AS message;
        LEAVE delete_account;
	END IF;
    
    DELETE FROM `Account` WHERE `AccountName` = InAccount;

END//

DELIMITER ;

CALL `Login`('Test Account', 'Test Password');
CALL `Create_Room`('Test Room', 'Test Account');
CALL `Layout_Tiles`(1, 5, 5);
CALL `Create_Ability`();
CALL `Place_Ability_On_Tile`(1, 1);
CALL `Create_Player`('Test Account', 1);
CALL `Move_Player`(1, 1, 0, 1, 0);
CALL `Pickup_Ability`(1, 1);
CALL `Update_Score`(1);
SELECT `Get_Score`(1) AS player_score;
CALL `Get_Leaderboard`(1);
CALL `Kill_Room`(1);
CALL `Delete_Account`('Test Account', 1);
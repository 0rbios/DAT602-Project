USE gamedb;

DROP PROCEDURE IF EXISTS Login;
DROP PROCEDURE IF EXISTS Create_Account;
DROP PROCEDURE IF EXISTS Create_Abilities;
DROP PROCEDURE IF EXISTS Create_Room;
DROP PROCEDURE IF EXISTS Layout_Tiles;
DROP PROCEDURE IF EXISTS Place_Ability_On_Tile;
DROP PROCEDURE IF EXISTS Create_Player;
DROP PROCEDURE IF EXISTS Move_Player;
DROP PROCEDURE IF EXISTS Glitch_Ability;
DROP FUNCTION IF EXISTS Random_Tile;
DROP PROCEDURE IF EXISTS Pickup_Ability;
DROP PROCEDURE IF EXISTS Drop_Ability;
DROP PROCEDURE IF EXISTS Update_Score;
DROP FUNCTION IF EXISTS Get_Score;
DROP PROCEDURE IF EXISTS Get_Leaderboard;
DROP PROCEDURE IF EXISTS Find_Abilities;
DROP PROCEDURE IF EXISTS Kill_Room;
DROP PROCEDURE IF EXISTS Update_Account;
DROP PROCEDURE IF EXISTS Delete_Account;
DROP PROCEDURE IF EXISTS Update_Player;
DROP PROCEDURE IF EXISTS Send_Message;
DROP PROCEDURE IF EXISTS Get_Messages;

DELIMITER //

-- Account login, including lock out
CREATE PROCEDURE Login(
	IN In_Username VARCHAR(32),
	IN In_Password VARCHAR(32)
)
BEGIN

	-- Redirect: If requested account name doesn't exist
	IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username) THEN
		CALL Create_Account(In_Username, In_Password);
        
    -- Error: If requested password does not match requested username
	ELSEIF EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username AND `Password` = In_Password) THEN
		SELECT 'Login Failed' AS message;
        
		UPDATE `account`
			SET LoginAttempts = LoginAttempts + 1
			WHERE AccountName = In_Username;
	
    -- Error: If requested account is locked
    ELSEIF (SELECT `Locked` FROM `account` WHERE AccountName = In_Username LIMIT 1) <> 0 THEN
		SELECT 'Account Locked' AS message;
    
	-- Return the username and reset the login attempts
	ELSE
		SELECT AccountName
		FROM `account`
		WHERE EXISTS (
						SELECT *
                        FROM `account`
                        WHERE AccountName = In_Username);
		
		UPDATE `account`
			SET LoginAttempts = 0
			WHERE EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username);
	END IF;
	
END//

-- Account registration
CREATE PROCEDURE Create_Account (
	IN IN_Username VARCHAR(32),
	IN IN_Password VARCHAR(32)
)
BEGIN

	-- Error: If requested account name already exists
	IF EXISTS (SELECT * FROM `account` WHERE AccountName = IN_Username) THEN
		SELECT 'Account name already exists' AS message;
	
    -- Create the new account with the requested username and password
	ELSE
		INSERT INTO `account` (AccountName, `Password`)
			VALUES (IN_Username, IN_Password);
            
		SELECT * FROM `account`;
	END IF;
    
END//

-- Creating a room and ability instances
CREATE PROCEDURE Create_Room(
	IN In_Name VARCHAR(32),
    IN In_Player VARCHAR(32)
)
BEGIN
	
    -- Error: Requested room owner account name doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = In_Player) THEN
		SELECT 'Invalid Account Name' AS message;
	
    -- Create the new room with the requested name and owner, then create new ability instances
    ELSE
		INSERT INTO room (RoomName, AccountName)
			VALUES (In_Name, In_Player);
		
		INSERT INTO abilityinstance (AbilityName)
			VALUES ('Piston Wreck');
	END IF;
    
END//

-- Laying out tiles on a game board
CREATE PROCEDURE Layout_Tiles(
	IN InRoom INT,
	IN mapX INT,
    IN mapY INT
)
BEGIN

    DECLARE tx INT DEFAULT 0;
    DECLARE ty INT DEFAULT 0;
    
    -- Error: If requested room doesn't exist
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = INRoom) THEN
		SELECT 'Room Does Not Exist' AS message;
	
    -- Loop across and then down the x and y of the grid, creating each tile
	ELSE
		tileX: LOOP
			SET ty = 0;
		
			tileY: LOOP
				INSERT INTO tile (XPos, YPos, RoomID)
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
	END IF;

END//

-- Placing an ability on a tile
CREATE PROCEDURE Place_Ability_On_Tile(
	IN InAbilityInstance INT,
    IN InTile INT
)
BEGIN

	-- Error: If requested tile doesn't exist
	IF NOT EXISTS (SELECT * FROM tile WHERE TileID = InTile) THEN
		SELECT 'Tile does not exist' AS message;
	
    -- Error: If requested ability instance doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM abilityinstance WHERE AbilityID = InAbilityInstance) THEN
			SELECT 'Ability instance does not exist' AS message;
	
    -- Put item on tile
	ELSE
		INSERT INTO Tile_Ability (Placed, TileID, AbilityID)
			VALUES (CURRENT_TIMESTAMP(), InTile, InAbilityInstance);
	END IF;

END//

-- Create player and place on home tile
CREATE PROCEDURE Create_Player(
	IN InAccountName VARCHAR(32),
    IN InRoomID INT
)
BEGIN

	-- Error: If requested account doesn't exist
	IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccountName) THEN
		SELECT 'Account does not exist' AS message;

	-- Error: If requested room doesn't exist
    ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoomID) THEN
		SELECT 'Room does not exist' AS message;
	
    -- Create a new player with the requested account on the requested room and place them on the tile at 0,0
    ELSE
		INSERT INTO player (CurrentEnergy, CurrentHealth, AccountName, RoomID, Sprite)
			VALUES (10, 10, InAccountName, InRoomID, './Player.png');

		-- Places the player with the given account and room who also has the largest auto_incementing ID onto the tile with position 0,0 on the given table.
		INSERT INTO player_tile (TileID, PlayerID, `Timestamp`)
			VALUES (
					(SELECT TileID FROM tile WHERE RoomID = InRoomID AND XPos = 0 AND YPos = 0),
					(SELECT PlayerID FROM player WHERE AccountName = InAccountName AND RoomID = InRoomID ORDER BY PlayerID LIMIT 1),
					CURRENT_TIMESTAMP()
					);
	END IF;

END//

-- Find available movement tiles and move player
CREATE PROCEDURE Move_Player(
    IN Player INT,
	IN MoveX INT,
    IN MoveY INT,
	IN SearchRadius INT,
    IN AllowDiagonal BIT
)
BEGIN

	DECLARE playerX INT;
	DECLARE playerY INT;

	-- Error: If procedure tries to move diagonally without diagonal flag
	IF AllowDiagonal = 0 THEN
		IF MoveX AND MoveY <> 0 THEN
			SELECT 'Diagonal movement on non-diagonal check' AS message;
		END IF;
            
	-- Error: If requested radius is too small
    ELSEIF SearchRadius < 1 THEN
		SELECT 'Search radius too small' AS message;
	
    -- Error: If requested player doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Player not found' AS message;
    
    ELSE
    
		-- Get the player's current position
		SET playerX = (SELECT XPos FROM tile WHERE TileID = (SELECT TileID FROM player_tile WHERE PlayerID = Player ORDER BY `Timestamp` LIMIT 1));
		SET playerY = (SELECT YPos FROM tile WHERE TileID = (SELECT TileID FROM player_tile WHERE PlayerID = Player ORDER BY `Timestamp` LIMIT 1));

		-- Error: Requested tile is out of range
		IF NOT EXISTS (WITH surroundingtiles AS 
			(
				SELECT *
				FROM tile
				WHERE XPos >= playerX - searchRadius
					AND XPos <= playerX + searchRadius
					AND YPos >= playerY - searchRadius
					AND YPos <= playerY + searchRadius
					AND RoomID = (SELECT RoomID
									FROM player
									WHERE PlayerID = Player)
			) SELECT TileID FROM surroundingtiles WHERE XPos = MoveX AND YPos = MoveY) THEN
			
            SELECT 'Tile out of range' AS message;
		
        -- Place the requested player on the requested tile
        ELSE
			INSERT INTO player_tile (TileID, PlayerID, Timestamp)
				VALUES ((SELECT TileID FROM tile WHERE XPos = MoveX AND YPos = MoveY), Player, CURRENT_TIMESTAMP());
			
			SELECT * FROM player_tile;
            
		END IF;
	END IF;
END//

-- Glitch ability movement
CREATE PROCEDURE Glitch_Ability (
	IN AbilityInstance INT
)
BEGIN

	-- Error: If requested ability instance doesn't exist
	IF NOT EXISTS (SELECT * FROM abilityinstance WHERE AbilityID = AbilityInstance) THEN
		SELECT 'Ability instance does not exist' AS message;
    
    -- Error: If requested ability instance is in a player's inventory
    ELSEIF EXISTS (SELECT * FROM player_ability WHERE AbilityID = AbilityInstance AND Dropped IS NULL) THEN
		SELECT 'Ability is being held' AS message;
    
    -- Remove the requested ability instance from its tile and add it to the player's inventory
    ELSE
        IF NOT EXISTS (SELECT * FROM tile_ability WHERE Placed = CURRENT_TIMESTAMP AND AbilityID = AbilityInstance) THEN
			
			UPDATE tile_ability
				SET Removed = CURRENT_TIMESTAMP()
				WHERE AbilityID = AbilityInstance
					AND Removed;
		
			INSERT INTO tile_ability (TileID, AbilityID, Placed)
				VALUE (Random_Tile(
							(SELECT t.RoomID
							 FROM tile_ability AS ta
							 JOIN abilityinstance AS ai
								ON ai.AbilityID = ta.AbilityID
							 JOIN tile AS t
								ON t.TileID = ta.TileID
							 WHERE ta.AbilityID = AbilityInstance)
							), AbilityInstance, CURRENT_TIMESTAMP());
                            
		END IF;
			
		SELECT * FROM tile_ability;
	END IF;

END//

-- Select random tile
CREATE FUNCTION Random_Tile(
	Room INT
) RETURNS INT DETERMINISTIC
BEGIN
	
    -- Error: If the requested room doesn't exist
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		RETURN 0;
	END IF;

	-- Get a table with all of the room's tiles, shuffles them and then returns the top one's ID
	RETURN (SELECT TileID FROM tile WHERE RoomID = Room ORDER BY RAND() LIMIT 1);
    
END//

-- Player acquiring inventory
CREATE PROCEDURE Pickup_Ability (
	IN Player INT,
    IN AbilityInstance INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Invalid player' AS message;
    
    -- Error: If requested ability instance doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM abilityinstance WHERE abilityID = AbilityInstance) THEN
		SELECT 'Invalid ability instance' AS message;
    
    -- Remove the requested item from its current tile and add it to the player's inventory
    ELSE
		UPDATE tile_ability
			SET Removed = CURRENT_TIMESTAMP()
			WHERE AbilityID = AbilityInstance
				AND Removed IS NULL;
		
		INSERT INTO player_ability (PlayerID, AbilityID, PickedUp)
			VALUES (Player, AbilityInstance, CURRENT_TIMESTAMP());
    END IF;
    
END//

-- Player removing inventory
CREATE PROCEDURE Drop_Ability (
	IN Player INT,
    IN AbilityInstance INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Invalid player' AS message;
    
    -- Error: If requested ability instance doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM abilityinstance WHERE abilityID = AbilityInstance) THEN
		SELECT 'Invalid ability instance' AS message;
    
    -- Error: If player isn't holding ability
    ELSEIF NOT EXISTS (SELECT * FROM player_ability WHERE AbilityID = AbilityInstance AND PlayerID = Player AND Dropped IS NULL) THEN
		SELECT 'Player is not holding that ability' AS message;
    
    -- Remove the requested item from its current tile and add it to the player's inventory
    ELSE
        IF NOT EXISTS (SELECT * FROM tile_ability WHERE Placed = CURRENT_TIMESTAMP AND AbilityID = AbilityInstance) THEN
			UPDATE player_ability
				SET Dropped = CURRENT_TIMESTAMP()
				WHERE AbilityID = AbilityInstance
					AND Dropped IS NULL;
		
			INSERT INTO tile_ability (TileID, AbilityID, Placed)
				VALUES ((SELECT TileID FROM player_tile WHERE PlayerID = Player ORDER BY `Timestamp` LIMIT 1), AbilityInstance, CURRENT_TIMESTAMP());
                
		END IF;
        
    END IF;
    
END//

-- Update score
CREATE PROCEDURE Update_Score (
	IN Player INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Invalid Player ID' AS message;

	-- Default: If there is nothing in the inventory score becomes 0
    ELSEIF NOT EXISTS (SELECT * FROM player_ability WHERE PlayerID = Player AND Dropped IS NULL) THEN
		UPDATE player
			SET CurrentScore = 0
			WHERE PlayerID = Player;
	
    -- Set the player's score to the sum of the values of all abilities they are currently holding !! THIS IS MISSING THE PLAYERS SCORE FROM COMBAT
    ELSE
		UPDATE player
			SET CurrentScore = (
									SELECT SUM(a.`Value`)
									FROM player_ability AS pa
									JOIN abilityinstance AS ai
										ON pa.AbilityID = ai.AbilityID
									JOIN ability AS a
										ON ai.AbilityName = a.AbilityName
									WHERE pa.Dropped IS NULL
									GROUP BY pa.PlayerID
										HAVING pa.PlayerID = 1
								  )
			WHERE PlayerID = Player;
	END IF;
    
    -- Update the high score if necessary
    IF (SELECT CurrentScore FROM player) > (SELECT HighScore FROM player) THEN
		UPDATE player
        SET HighScore = CurrentScore
        WHERE PlayerID = Player;
	END IF;

END//

-- Get score
CREATE FUNCTION Get_Score ( Player INT )
RETURNS INT DETERMINISTIC
BEGIN

	-- Default: If requested player doesn't exist return 0
	IF NOT EXISTS (SELECT CurrentScore FROM player WHERE PlayerID = Player) THEN
		RETURN 0;
	END IF;

	-- Return the player's current score value
	RETURN (SELECT CurrentScore FROM player WHERE PlayerID = Player);
    
END//

-- Get leaderboard
CREATE PROCEDURE Get_Leaderboard(
	IN Room INT
)
BEGIN

	-- Error: If requested room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Invalid Room' AS message;

	-- Get the player names and high scores from the requested room
	ELSE
		SELECT AccountName, HighScore FROM player WHERE RoomID = Room;
	END IF;

END//

-- Locate current position of each ability
CREATE PROCEDURE Find_Abilities(
	IN Room INT
)
BEGIN
	
    -- Error: If the requested room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Room does not exist' AS message;
    
    -- Get a list of all abilties combining the tile and player lists and then getting only the ones that haven't been removed
    ELSE
		WITH ability_locations (added, removed, tile, player, abilityid) AS (
			SELECT tile_ability.Placed, tile_ability.Removed, tile_ability.TileID, NULL, tile_ability.AbilityID
			FROM tile_ability
			JOIN tile
				ON tile.TileID = tile_ability.TileID
			WHERE tile.RoomID = Room
			
			UNION
			
			SELECT player_ability.PickedUp, player_ability.Dropped, NULL, player_ability.PlayerID, player_ability.AbilityID
			FROM player_ability
			JOIN player
				ON player.PlayerID = player_ability.PlayerID
			WHERE player.RoomID = Room
		)
		SELECT * FROM ability_locations WHERE removed IS NULL;
	END IF;

END//

-- Kill running games
CREATE PROCEDURE Kill_Room(
	IN Room INT
)
BEGIN

	-- Error: If the requested room does not exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Room does not exist' AS message;
	
    -- Delete the requested room
    ELSE
		DELETE FROM room WHERE RoomID = Room;
	END IF;

END//

-- Update data of an account
CREATE PROCEDURE Update_Account(
	IN InAccount VARCHAR(32),
    IN NewPassword VARCHAR(32),
    IN IsAdmin BIT,
    IN IsLocked BIT
)
BEGIN

	-- Error: If requested account doesn't exist
	IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account does not exist' AS message;
    
    -- Update the requested account with the given data
    ELSE
		UPDATE `account`
			SET `Password` = NewPassword,
				`Admin`= IsAdmin,
				`Locked` = IsLocked
			WHERE AccountName = InAccount;
		
		SELECT * FROM `account`;
	END IF;

END//

-- Delete an account
CREATE PROCEDURE Delete_Account(
	IN InAccount VARCHAR(32),
    IN Confirm BIT
)
BEGIN

	-- Error: If the account deletion wasn't confirmed
	IF Confirm <> 1 THEN
		SELECT 'Account Deletion Cancelled' AS message;
    
    -- Error: If the requested account doesn't exist
    ELSEIF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account does not exist' AS message;
    
    -- Delete the requested account
    ELSE
		DELETE FROM `account` WHERE AccountName = InAccount;
	END IF;

END//

-- Send Message
CREATE PROCEDURE Send_Message(
	IN Message VARCHAR(128),
    IN Player INT
)
BEGIN

	-- Error: If the player ID doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Invalid Player' AS message;
        
	ELSE
		INSERT INTO message (PlayerID, `Text`, SendTime)
			VALUES (Player, Message, CURRENT_TIMESTAMP());
	
    END IF;

END//

-- Read Messages
CREATE PROCEDURE Get_Messages(
	IN Room INT
)
BEGIN

	-- Error: If the room doesn't exist
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Invalid Room' AS message;
	ELSE
		SELECT m.*
		FROM message m
        JOIN player p
        ON p.PlayerID = m.PlayerID
        WHERE p.RoomID = Room;
	END IF;

END//

-- Combat Win


-- Combat Lose


-- Update Player Data
CREATE PROCEDURE Update_Player (
	IN Player INT,
    IN Score_Current INT,
    IN Score_High INT,
    IN InHealth INT,
    IN InEnergy INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT '{Player does not exist' AS message;
    
    -- Update the requested player with the given data
    ELSE
		UPDATE `player`
			SET High_Score = Score_High,
				Current_Score = Score_Current,
                Health = InHealth,
                Energy = InEnergy
			WHERE PlayerID = Player;
		
		SELECT * FROM `player`;
	END IF;

END//

DELIMITER ;

-- Test Execution
CALL Login('Test Account', 'Test Password');					-- Try to log in (Expected result: account details for Test Account)
CALL Create_Room('Test Room', 'Test Account');					-- Create a new room
CALL Layout_Tiles(1, 5, 5);										-- Layout the tiles in the room
CALL Place_Ability_On_Tile(1, 1);								-- Place abilities on the tiles
CALL Create_Player('Test Account', 1);							-- Create a new player in the room
CALL Move_Player(1, 1, 0, 1, 0);								-- Move the player to 1,0 within radius 1 and disallowing diagonal movement (Expected result: All player tile extries)
CALL Glitch_Ability(1);											-- Move the ability (Expected result: All tile ability entries)
CALL Pickup_Ability(1, 1);										-- Make the player pick up the ability
CALL Send_Message('Test Message', 1);
CALL Get_Messages(1);
CALL Update_Score(1);											-- Update the player's score
SELECT Get_Score(1) AS player_score;							-- Get the player's score (Expected result: The score for the test player)
CALL Get_Leaderboard(1);										-- Get the room's leaderboard (Expected result: Should be the same as last command)
CALL Find_Abilities(1);											-- Find the current location of all abilities in the room (Expected result: The current location of the item)
CALL Drop_Ability(1, 1);										-- Make the player drop the ability
CALL Update_Score(1);											-- Update the player's score
SELECT Get_Score(1) AS player_score;							-- Get the player's score (Expected result: The score for the test player)
CALL Get_Leaderboard(1);										-- Get the room's leaderboard (Expected result: Should be the same as last command)
CALL Find_Abilities(1);											-- Find the current location of all abilities in the room (Expected result: The current location of the item)
CALL Kill_Room(1);												-- Kill the room
CALL Update_Account('Test Account', 'New Password', 1, 1);		-- Update the account (Expected result: the changed account details)
CALL Delete_Account('Test Account', 1);							-- Delete the account

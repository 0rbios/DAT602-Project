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
DROP PROCEDURE IF EXISTS Engage_Combat;
DROP PROCEDURE IF EXISTS Disengage_Combat;
DROP PROCEDURE IF EXISTS Attack;
DROP PROCEDURE IF EXISTS Resolve_Combat;
DROP FUNCTION IF EXISTS Get_Instance;

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
		UPDATE `account`
			SET LoginAttempts = 0
			WHERE EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username);
            
		SELECT AccountName
		FROM `account`
		WHERE EXISTS (
						SELECT *
                        FROM `account`
                        WHERE AccountName = In_Username);
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
	
    -- Create the new account with the requested username and password and log in to it
	ELSE
		INSERT INTO `account` (AccountName, `Password`)
			VALUES (IN_Username, IN_Password);
            
		CALL Login(IN_Username, IN_Password);
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
		
        SET @NewRoomID = (SELECT RoomID FROM room WHERE AccountName = In_Player LIMIT 1);
        
        CALL Layout_Tiles(@NewRoodID, 10, 10);
        
        CALL Place_Ability_On_Tile("Piston Wreck", 1);
        
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
	IN InAbility VARCHAR(24),
    IN InTile INT
)
BEGIN

	-- Error: If requested tile doesn't exist
	IF NOT EXISTS (SELECT * FROM tile WHERE TileID = InTile) THEN
		SELECT 'Tile does not exist' AS message;
	
    -- Error: If requested ability instance doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM ability WHERE AbilityName = InAbility) THEN
			SELECT 'Ability does not exist' AS message;
	
    -- Create the item instance and put it on the tile
	ELSE
		INSERT INTO abilityinstance (AbilityName)
			VALUES (InAbility);
            
		INSERT INTO Tile_Ability (Placed, TileID, AbilityID)
			VALUES (CURRENT_TIMESTAMP(), InTile, (SELECT Get_Instance(AbilityName)));
	END IF;

END//

-- Create player and place on home tile
CREATE PROCEDURE Create_Player(
	IN InAccountName VARCHAR(32),
    IN InRoomID INT,
    IN Class VARCHAR(32)
)
BEGIN

	-- Error: If requested account doesn't exist
	IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccountName) THEN
		SELECT 'Account does not exist' AS message;

	-- Error: If requested room doesn't exist
    ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoomID) THEN
		SELECT 'Room does not exist' AS message;
	
    -- Error: If the class doesn't exist
    ELSEIF NOT EXISTS (SELECT * FROM class WHERE ClassName = Class) THEN
		SELECT 'Invalid class' AS message;
    
    ELSE
		-- Attempt to place the player back on their last tile
		IF EXISTS (SELECT * FROM player WHERE RoomID = InRoomID AND PlayerID) THEN
			UPDATE player
			SET `Active` = 1
            WHERE AccountName = InAccountName
				AND RoomID = InRoomID;
    
		-- Create a new player with the requested account on the requested room and place them on the tile at 0,0
        ELSE
			INSERT INTO player (CurrentEnergy, CurrentHealth, AccountName, RoomID, ClassName)
				VALUES (10, 10, InAccountName, InRoomID, Class);

			-- Places the player with the given account and room onto the tile with position 0,0 on the given table.
			INSERT INTO player_tile (TileID, PlayerID, `Timestamp`)
				VALUES (
						(SELECT TileID FROM tile WHERE RoomID = InRoomID AND XPos = 0 AND YPos = 0),
						(SELECT PlayerID FROM player WHERE AccountName = InAccountName AND RoomID = InRoomID),
						CURRENT_TIMESTAMP()
						);
		END IF;
                        
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
			INSERT INTO player_tile (TileID, PlayerID, `Timestamp`)
				VALUES ((SELECT TileID FROM tile WHERE XPos = MoveX AND YPos = MoveY), Player, CURRENT_TIMESTAMP());
                
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
            
		CALL Update_Score(Player);
        
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
			
            CALL Update_Score(Player);
            
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

	-- Default: If there is nothing in the inventory score is just the battle score
    ELSEIF NOT EXISTS (SELECT * FROM player_ability WHERE PlayerID = Player AND Dropped IS NULL) THEN
		UPDATE player
			SET CurrentScore = (SELECT BattleScore FROM player WHERE PlayerID = Player)
			WHERE PlayerID = Player;
	
    -- Set the player's score to the sum of the values of all abilities they are currently holding plus their battle score
    ELSE
		UPDATE player
			SET CurrentScore = (
									SELECT (SUM(a.`Value`) + BattleScore)
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
		
	END IF;

END//

-- Engage Combat
CREATE PROCEDURE Engage_Combat(
	IN Player1 INT,
    IN Player2 INT
)
BEGIN

	-- Error: If Player 1 or 2 don't exist
    IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player1 OR PlayerID = Player2) THEN
		SELECT 'Invalid player(s)' AS message;
    
	-- Error: If Player 1 or 2 is already engaged
    ELSEIF NOT EXISTS (SELECT * FROM player WHERE (PlayerID = Player1 OR PlayerID = Player2) AND Combatant IS NULL) THEN
		SELECT 'Player(s) already engaged' AS message;
    
    -- Error: If Player 1 and Player 2 are the same player
    ELSEIF Player1 = Player2 THEN
		SELECT 'Identical player' AS message;
    
    -- Error: If Player 1 and Player 2 are not in the same room
    ELSEIF (SELECT RoomID FROM player WHERE PlayerID = Player1) <> (SELECT RoomID FROM player WHERE PlayerID = Player2) THEN
		SELECT 'Players are in different rooms' AS message;
    
	-- Error: If Player 1 and Player 2 are too many tiles apart    
    ELSEIF ABS((SELECT t.XPos + t.YPos FROM tile t JOIN player_tile pt ON pt.TileID = t.TileID WHERE pt.PlayerID = Player1 ORDER BY `Timestamp` LIMIT 1) - (SELECT t.XPos + t.YPos FROM tile t JOIN player_tile pt ON pt.TileID = t.TileID WHERE pt.PlayerID = Player2 ORDER BY `Timestamp` LIMIT 1)) <> 1 THEN
		SELECT 'Players too far apart' AS message;
    
    -- Set each other as combatants
	ELSE
		UPDATE player
        SET Combatant = CASE
			WHEN PlayerID = Player1 THEN Player2
            WHEN PlayerID = Player2 THEN Player1
            END;

	END IF;

END//

-- Disengage Combat
CREATE PROCEDURE Disengage_Combat(
	IN Player INT
)
BEGIN

	-- Error: If player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player) THEN
		SELECT 'Invalid Player' AS message;

	-- Error: If player is not in combat
	ELSEIF (SELECT Combatant FROM player WHERE PlayerID = Player) IS NULL THEN
		SELECT 'Player not in combat' AS messsage;

	-- Set both player's combatant to null
	ELSE 
		SET @OtherPlayer = (SELECT Combatant FROM player WHERE PlayerID = Player);
        
		UPDATE player
        SET Combatant = NULL
        WHERE PlayerID = Player
			OR PlayerID = @OtherPlayer;  

	END IF;

END//

-- Attack Combatant
CREATE PROCEDURE Attack(
	IN Ability INT
)
BEGIN

	-- Find the player that is currently holding the ability
	SET @attacker = (SELECT PlayerID FROM player_ability WHERE AbilityID = Ability AND Dropped IS NULL);

	-- Error: If no one is holding ability
    IF @attacker IS NULL THEN
		SELECT 'Ability not being held' AS message;
    
	-- Error: If the ability can't be used in combat
    ELSEIF (SELECT Combat FROM ability WHERE AbilityName = (SELECT AbilityName FROM abilityinstance WHERE AbilityID = Ability)) = 0 THEN
		SELECT 'Combat cannot be used in combat' AS message;
    
    -- Error: If attacker has no target
	ELSEIF (SELECT Combatant FROM player WHERE PlayerID = @attacker) IS NULL THEN
		SELECT 'No target' AS message;
	
    -- Check: Does attacker have enough energy
    ELSEIF (SELECT Cost FROM ability WHERE AbilityName = (SELECT AbilityName FROM abilityinstance WHERE AbilityID = Ability))
			>
            (SELECT CurrentEnergy FROM player WHERE PlayerID = @attacker) THEN
		SELECT 'Not enough energy' AS message;
        
	ELSE
		-- Get target player's id
        SET @target = (SELECT Combatant FROM player WHERE PlayerID = @attacker);
		
		-- Calculate damage output
        SET @damage = FLOOR(
						(SELECT `Value` FROM player_stat WHERE StatName = 'Strength' AND PlayerID = @attacker) *
						(SELECT Damage FROM ability WHERE AbilityName = (SELECT AbilityName FROM abilityinstance WHERE AbilityID = Ability))
                      );
        
		-- Reduce target health
		UPDATE player
        SET CurrentHealth = CurrentHealth - @damage
        WHERE PlayerID = @target;
        
		-- Reduce attacker energy
		UPDATE player
        SET CurrentEnergy = CurrentEnergy - (SELECT Cost FROM ability WHERE AbilityName = (SELECT AbilityName FROM abilityinstance WHERE AbilityID = Ability))
        WHERE PlayerID = @attacker;
        
		-- Check target health
		IF (SELECT CurrentHealth FROM player WHERE PlayerID = @target) <= 0 THEN
			CALL Resolve_Combat(@attacker, @target);
		END IF;

	END IF;

END//

-- Combat Outcome
CREATE PROCEDURE Resolve_Combat(
	IN Winner INT,
    IN Loser INT
)
BEGIN

	-- Error: If one of the player's doesn't exist
    IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Winner OR PlayerID = Loser) THEN
		SELECT 'Player(s) do not exist' AS message;

	ELSE
		-- Add score increase to winner's battle score and reset the loser's battle score
		UPDATE player
		SET BattleScore = CASE
			WHEN PlayerID = Winner THEN BattleScore + CEIL((SELECT CurrentScore FROM player WHERE PlayerID = Loser) / 10)
													  +
													  (SELECT SUM(`Value`) FROM player_stat WHERE PlayerID = Loser)
			WHEN PlayerID = Loser THEN 0
            END;

		-- Remove all items from loser's inventory
		UPDATE player_ability
        SET Dropped = CURRENT_TIMESTAMP()
		WHERE PlayerID = Loser
			AND	Dropped IS NULL;
        
		-- Recreate their starting ability instance
		INSERT INTO abilityinstance (AbilityName)
			VALUES ((SELECT AbilityName
					 FROM class c
                     JOIN player p
						ON p.ClassName = c.ClassName
                     WHERE p.PlayerID = Loser)
					);
        
		-- Add recreated ability to inventory
        INSERT INTO player_ability (PlayerID, AbilityID, PickedUp)
			VALUES (Loser, (SELECT Get_Instance((SELECT AbilityName
													FROM class c
                                                    JOIN player p
														ON p.ClassName = c.ClassName
													WHERE p.PlayerID = Loser))), CURRENT_TIMESTAMP());
        
		-- Move the loser to the home tile
		INSERT INTO player_tile (PlayerID, TileID, `Timestamp`)
			VALUE (Loser,
					(SELECT TileID
					 FROM tile
                     WHERE RoomID = (
										SELECT RoomID
										FROM player
                                        WHERE PlayerID = Loser
									)
						AND  XPos = 0
                        AND YPos = 0),
                    CURRENT_TIMESTAMP());
        
		-- Update both player's scores 
		CALL Update_Score(Winner);
        CALL Update_Score(Loser);

	END IF;

END//

-- Get a free instance of a given ability
CREATE FUNCTION Get_Instance(In_Ability VARCHAR(24))
RETURNS INT
BEGIN
	-- Find an unused ability instance for the given ability
	RETURN (
			SELECT AbilityID
			FROM abilityinstance
			WHERE AbilityID NOT IN (
									SELECT AbilityID
									FROM player_tile pa
									JOIN tile_ability ta
									)
				AND AbilityName = In_Ability
			LIMIT 1
			);
END//

DELIMITER ;
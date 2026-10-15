DROP DATABASE IF EXISTS gamedb;
CREATE DATABASE gamedb;
USE gamedb;

DELIMITER //

-- Generate the database
CREATE PROCEDURE Generate_Database()
BEGIN
	CREATE TABLE `account` (
		AccountName VARCHAR(32),
		`Password` VARCHAR(32) NOT NULL,
		`Admin` BIT NOT NULL DEFAULT 0,
		`Locked` BIT NOT NULL DEFAULT 0,
		LoginAttempts INT(1) NOT NULL DEFAULT 0,
		PRIMARY KEY (AccountName)
	);

	CREATE TABLE room (
		RoomID INT AUTO_INCREMENT,
		RoomName VARCHAR(32) NOT NULL,
		AccountName VARCHAR(32) NOT NULL,
		PRIMARY KEY (RoomID),
		CONSTRAINT fk_account_room
			FOREIGN KEY (AccountName)
			REFERENCES `account`(AccountName)
            ON DELETE CASCADE
	);
    
	CREATE TABLE ability (
		AbilityName VARCHAR(24),
		`Description` VARCHAR(255) NOT NULL,
		`Value` INT(5) NOT NULL,
		Cost INT(5) NOT NULL,
		Combat BIT NOT NULL,
		Damage INT(3),
		Glitched BIT NOT NULL DEFAULT 0,
		Sprite VARCHAR(32) NOT NULL,
		PRIMARY KEY (AbilityName)
	);

	CREATE TABLE abilityinstance (
		AbilityID INT AUTO_INCREMENT,
		AbilityName VARCHAR(24) NOT NULL,
        PRIMARY KEY (AbilityID),
        CONSTRAINT fk_abilityinstance_ability
			FOREIGN KEY (AbilityName)
            REFERENCES ability(AbilityName)
            ON DELETE CASCADE
    );
    
    CREATE TABLE class (
		ClassName VARCHAR(32),
        AbilityName VARCHAR(24),
		Sprite VARCHAR(32) NOT NULL,
        PRIMARY KEY (ClassName),
        CONSTRAINT fk_class_ability
			FOREIGN KEY (AbilityName)
            REFERENCES ability(AbilityName)
            ON DELETE CASCADE
    );
    
	CREATE TABLE stat (
		StatName VARCHAR(16),
		`MaxValue` INT NOT NULL,
		PRIMARY KEY (StatName)
	);
    
    CREATE TABLE class_stat(
		ClassName VARCHAR(32),
        StatName VARCHAR(16) NOT NULL,
        Amount INT NOT NULL,
        PRIMARY KEY (ClassName, StatName),
        CONSTRAINT fk_class_stat_class
			FOREIGN KEY (ClassName)
            REFERENCES class(ClassName)
            ON DELETE CASCADE,
        CONSTRAINT fk_class_stat_stat
			FOREIGN KEY (StatName)
            REFERENCES stat(StatName)
            ON DELETE CASCADE
    );
    
	CREATE TABLE player (
		PlayerID INT AUTO_INCREMENT,
        `Active` BIT DEFAULT 1 NOT NULL,
		CurrentScore INT NOT NULL DEFAULT 0,
		HighScore INT NOT NULL DEFAULT 0,
		CurrentEnergy INT NOT NULL,
		CurrentHealth INT NOT NULL,
		AccountName VARCHAR(32) NOT NULL,
		RoomID INT NOT NULL,
        Combatant INT UNIQUE,
        ClassName VARCHAR(32) NOT NULL,
        BattleScore INT NOT NULL DEFAULT 0,
		PRIMARY KEY (PlayerID),
		CONSTRAINT fk_player_account
			FOREIGN KEY (AccountName)
			REFERENCES `account`(AccountName)
            ON DELETE CASCADE,
		CONSTRAINT fk_player_room
			FOREIGN KEY (RoomID)
			REFERENCES room(RoomID)
            ON DELETE CASCADE,
		CONSTRAINT fk_player_player
			FOREIGN KEY (Combatant)
            REFERENCES player(PlayerID)
            ON DELETE CASCADE,
		CONSTRAINT fk_player_class
			FOREIGN KEY (ClassName)
            REFERENCES class(ClassName)
            ON DELETE CASCADE
	);

	CREATE TABLE tile (
		TileID INT AUTO_INCREMENT,
		XPos INT NOT NULL,
		YPos INT NOT NULL,
		RoomID INT NOT NULL,
		PRIMARY KEY (TileID),
		CONSTRAINT fk_tile_room
			FOREIGN KEY (RoomID)
			REFERENCES room(RoomID)
            ON DELETE CASCADE
	);

	CREATE TABLE message (
		PlayerID INT,
		SendTime TIMESTAMP,
		`Text` VARCHAR(128) NOT NULL,
		PRIMARY KEY (PlayerID, SendTime, `Text`),
		CONSTRAINT fk_message_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID)
            ON DELETE CASCADE
	);

	CREATE TABLE statchange (
		AbilityName VARCHAR(24),
		StatName VARCHAR(16),
		Amount INT(2) NOT NULL,
		PRIMARY KEY (AbilityName, StatName),
		CONSTRAINT fk_statchange_ability
			FOREIGN KEY (AbilityName)
			REFERENCES ability(AbilityName)
            ON DELETE CASCADE,
		CONSTRAINT fk_statchange_stat
			FOREIGN KEY (StatName)
			REFERENCES stat(StatName)
            ON DELETE CASCADE
	);

	CREATE TABLE player_stat (
		StatName VARCHAR(16),
		PlayerID INT,
		`Value` INT NOT NULL,
		PRIMARY KEY (StatName, PlayerID),
		CONSTRAINT fk_playerstat_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID)
            ON DELETE CASCADE,
		CONSTRAINT fk_playerstat_stat
			FOREIGN KEY (StatName)
			REFERENCES stat(StatName)
            ON DELETE CASCADE
	);

	CREATE TABLE player_ability (
		PickedUp TIMESTAMP,
		AbilityID INT,
		PlayerID INT,
		Dropped TIMESTAMP,
		PRIMARY KEY (PickedUp, AbilityID, PlayerID),
		CONSTRAINT fk_playerability_abilityinstance
			FOREIGN KEY (AbilityID)
			REFERENCES abilityinstance(AbilityID)
            ON DELETE CASCADE,
		CONSTRAINT fk_playerability_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID)
            ON DELETE CASCADE
	);

	CREATE TABLE player_tile (
		TileID INT,
		PlayerID INT,
		MovedOn TIMESTAMP,
		MovedOff TIMESTAMP,
		PRIMARY KEY (TileID, PlayerID, MovedOn),
		CONSTRAINT fk_playertile_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID)
            ON DELETE CASCADE,
		CONSTRAINT fk_playertile_tile
			FOREIGN KEY (TileID)
			REFERENCES tile(TileID)
            ON DELETE CASCADE
	);

	CREATE TABLE tile_ability (
		Placed TIMESTAMP,
		TileID INT,
		AbilityID INT,
        Removed TIMESTAMP,
		PRIMARY KEY (Placed, TileID, AbilityID),
		CONSTRAINT fk_tileability_tile
			FOREIGN KEY (TileID)
			REFERENCES tile(TileID)
            ON DELETE CASCADE,
		CONSTRAINT fk_tileability_abilityinstance
			FOREIGN KEY (AbilityID)
			REFERENCES abilityinstance(AbilityID)
            ON DELETE CASCADE
	);
    
    -- Creates the games statistics
    INSERT INTO stat (StatName, `MaxValue`)
		VALUES ('Strength', 100),
			   ('Speed', 100),
               ('Energy', 100),
               ('Health', 100);
    
	-- Create all of the games abilities
    INSERT INTO ability (AbilityName, `Description`, `Value`, Cost, Damage, Sprite, Glitched, Combat)
		VALUES ('Iron Core', '+1 Health | -1 Speed\nA forged iron core to increase the durability of a suit.', 5, 0, 0, './Assets/IronCore.png', 0, 0),
				('Steel Core', '+3 Health | -2 Speed\nA forged steel core to better increase the durability of a suit.', 10, 0, 0, './Assets/SteelCore.png', 0, 0),
				('Platinum Core', '+5 Health | -3 Speed\nA forged platinum core to greatly increase the durability of a suit.', 15, 0, 0, './Assets/PlatinumCore.png', 0, 0),
				('Loose Spring', '+1 Health | -1 Strength\nA stretched spring, not very springy but bends easily.', 5, 0, 0, './Assets/LooseSpring.png', 0, 0),
				('Tight Spring', '+1 Strength | +1 Energy | -2 Health\nA firm spring, plenty of potential energy but not very flexible.', 10, 0, 0, './Assets/TightSpring.png', 0, 0),
				('Overtightened Spring', '+3 Energy | +2 Strength | -4 Health\nA spring that seems to have somehow been twisted past its usual breaking point. Extremely high potential energy but will not hold up well to stress.', 15, 0, 0, './Assets/OvertightenedSpring.png', 0, 0),
				('Ping', 'Scan the surrounding area for signals. (Tile inventory will include surrounding tiles as well until player moves)', 12, 5, 0, './Assets/Ping.png', 0, 0),
				('Piston Wreck', 'Utilise the added force of the pistons in a suit to increase the power of a punch.', 6, 1, 2, './Assets/PistonWreck.png', 0, 1),
				('Wing Swipe', 'Swipe a suits wing (or arm) with the added assistance of its propulsion jet.', 6, 1, 2, './Assets/WingSwipe.png', 0, 1),
				('Claw Strike', 'Use a suit’s claws (or fist) to damage a target.', 6, 1, 2, './Assets/ClawStrike.png', 0, 1),
				('Hyper-Speed Kick', 'Utilise the fast bearings in a suit’s legs to kick a target at increased speed.', 6, 1, 2, './Assets/HyperSpeedKick.png', 0, 1),
				('Jump-Kick', 'Jump into the air and kick a target.', 10, 4, 5, './Assets/JumpKick.png', 0, 1),
				('Laser', 'Fire a high-powered laser at a target.', 16, 6, 10, './Assets/Laser.png', 1, 1),
				('Teleport', 'Phase-shift a suit and its occupant to a different place. (Move to any empty tile on the map)', 30, 10, 0, './Assets/Teleport.png', 1, 0),
				('Speed Shift', '+5 Speed\nA mechanical switch which makes it substantially faster to shift up (and down) speed levels of a suit.', 25, 0, 0, './Assets/SpeedShift.png', 0, 0),
				('Iron Plating', '+1 Health | -1 Energy\nForged iron plating for the exterior of a suit. Seems to interfere with energy conduction.', 5, 0, 0, './Assets/IronPlating.png', 0, 0),
				('Steel Plating', '+3 Health | -2 Energy\nForged steel plating for the exterior of a suit. Seems to interfere with energy conduction.', 10, 0, 0, './Assets/SteelPlating.png', 0, 0),
				('Platinum Plating', '+5 Health | -3 Energy\nForged platinum plating for the exterior of a suit. Seems to interfere with energy conduction.', 20, 0, 0, './Assets/PlatinumPlating.png', 0, 0),
				('Overcharge', '+5 Energy\nSend an excess amount of energy around the suit, disregarding component damage.', 28, 0, 0, './Assets/Overcharge.png', 1, 0),
				('Cell', '+1 Energy | -1 Strength\nAn energy cell to store energy for later use. Seems to bounce off of surfaces easily.', 3, 0, 0, './Assets/Cell.png', 0, 0),
				('Double-Cell', '+4 Energy | -2 Strength\nTwo energy cells to store more energy for later use. Seem to bounce off of surfaces easily.', 6, 0, 0, './Assets/DoubleCell.png', 0, 0),
				('Triple-Cell', '+6 Energy | -3 Strength\nThree energy cells to store a lot more energy for later use. Seem to bounce off of surfaces easily.', 12, 0, 0, './Assets/TripleCell.png', 0, 0),
				('Quad-Cell', '+8 Energy | -5 Strength\nFour energy cells to store an overwhelming amount of energy for later use. Seem to bounce off of surfaces easily. One might question the diminishing returns of so many cells.', 24, 0, 0, './Assets/QuadCell.png', 0, 0);
        
    -- Create the games classes
    INSERT INTO class (ClassName, AbilityName, Sprite)
		VALUES ('Gorilla', 'Piston Wreck', 'Gorilla Token'),
			   ('Eagle', 'Wing Swipe', 'Eagle Token'),
               ('Cheetah', 'Hyper-Speed Kick', 'Cheetah Token'),
               ('Tiger', 'Claw Strike', 'Tiger Token');
    
    -- Attaches the classes to statistics
	INSERT INTO class_stat (ClassName, StatName, Amount)
		VALUE ('Gorilla', 'Health', 1),
			  ('Gorilla', 'Strength', 1),
              ('Gorilla', 'Energy', -1),
              ('Gorilla', 'Speed', -1),
              ('Eagle', 'Health', 1),
			  ('Eagle', 'Strength', -1),
              ('Eagle', 'Energy', -1),
              ('Eagle', 'Speed', 1),
              ('Cheetah', 'Health', -1),
			  ('Cheetah', 'Strength', -1),
              ('Cheetah', 'Energy', 1),
              ('Cheetah', 'Speed', 1),
              ('Tiger', 'Health', -1),
			  ('Tiger', 'Strength', 1),
              ('Tiger', 'Energy', 1),
              ('Tiger', 'Speed', -1);
	
    -- Create an administrator account
    INSERT INTO `account` (AccountName, `Password`, `Admin`)
		VALUES ('admin', 'admin123', 1);

END //

-- Generate a set of test data
CREATE PROCEDURE Create_Test_Data ()
BEGIN

    -- Tests registration
    -- Tests creating a new account
	CALL Create_Account('V', 'V3nd3774');
	CALL Create_Account('John', 'Password123');
	CALL Create_Account('Amanda', 'HelloWorld');
	CALL Create_Account('Test', 'TestTest');
	CALL Create_Account('Ghostie', 'eits0hg');
    
	-- Tests login
	CALL Login('Ghostie', 'eits0hg');

	-- Tests laying out tiles on a game board
    -- Tests Placing items on tiles
	CALL Create_Room('Test Room', 'Ghostie');

	CALL Join_Room('Ghostie', 1, 'Gorilla');
	
    CALL Send_Message('Hello World!', 'Ghostie', 1);
    CALL Send_Message('Is this thing on?', 'Ghostie', 1);

	-- Tests player acquiring inventory
    -- Tests player score changing
	CALL Transfer_Abilities(-1, 1, 'Ghostie', 1);
	CALL Transfer_Abilities(-1, 2, 'Ghostie', 1);
	CALL Transfer_Abilities(-1, 2, 'Ghostie', 1);
    
    -- Tests player movement
    CALL Move_Player('Ghostie', 1, 0, 1, 1, 0);
    CALL Move_Player('Ghostie', 1, 1, 1, 1, 0);
    
    -- Tests moving an item
    CALL Glitch_Ability(1);
    
    -- Tests updating player data
    CALL Update_Player('Ghostie', 1, 100, 200);
    
    -- Tests deleting a player
    CALL Delete_Player('Ghostie', 1);
    
    -- Tests killing a game
    CALL Kill_Room(1);
    
END //

-- Account login, including lock out
CREATE PROCEDURE Login(
	IN In_Username VARCHAR(32),
	IN In_Password VARCHAR(32)
)
BEGIN

	-- Redirect: If requested account name doesn't exist
	IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username) THEN
		SELECT 'Account not found' AS message;
        
    -- Error: If requested password does not match requested username
	ELSEIF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = In_Username AND `Password` = In_Password) THEN
		UPDATE `account`
		SET LoginAttempts = LoginAttempts + 1
		WHERE AccountName = In_Username;
    
		IF (SELECT LoginAttempts FROM `account` WHERE AccountName = In_Username) > 5 THEN
			UPDATE `account`
            SET `Locked` = 1
            WHERE AccountName = In_Username;
		END IF;
    
		SELECT 'Login failed' AS message;
	
    -- Error: If requested account is locked
    ELSEIF (SELECT `Locked` FROM `account` WHERE AccountName = In_Username LIMIT 1) <> 0 THEN
		SELECT 'Account locked' AS message;
    
	-- Return the username and reset the login attempts
	ELSE
		UPDATE `account`
		SET LoginAttempts = 0
		WHERE AccountName = In_Username;
            
		SELECT 'Login success' AS message;
        
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
            
		SELECT 'Account created successfully' AS message;
        
	END IF;
    
END//

-- Creating a room and ability instances
CREATE PROCEDURE Create_Room(
	IN In_Name VARCHAR(32),
    IN In_Player VARCHAR(32)
)
BEGIN

	DECLARE i INT DEFAULT 1;
	
    -- Error: Requested room owner account name doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = In_Player) THEN
		SELECT 'Invalid account name' AS message;
	
    -- Create the new room with the requested name and owner, then create new ability instances
    ELSE
		INSERT INTO room (RoomName, AccountName)
			VALUES (In_Name, In_Player);
		
        SET @NewRoomID = (SELECT RoomID FROM room WHERE AccountName = In_Player LIMIT 1);
        
        SET @mapsize = 20;
        
        CALL Layout_Tiles(@NewRoomID, @mapsize, @mapsize);
        
        item_loop: LOOP
        
			IF i > (((@mapsize / 2) + 3) * 1.5) THEN
				LEAVE item_loop;
			END IF;
        
			CALL Place_Ability_On_Tile((SELECT AbilityName FROM ability LIMIT i, 1), Random_Tile(@NewRoomID));
            
            SET i = i + 1;
            
        END LOOP item_loop;
        
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
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room does not exist' AS message;
	
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

    -- Error: If the given x/y doesn't exist in the given room
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
			VALUES (CURRENT_TIMESTAMP(), InTile, (SELECT Get_Instance(InAbility)));
	END IF;

END//

-- Create player and place on home tile
CREATE PROCEDURE Join_Room(
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
		-- Attempt to place the player back on their last tile if they are already in the room
		IF EXISTS (SELECT * FROM player WHERE RoomID = InRoomID AND AccountName = InAccountName) THEN
			SET @player = (SELECT PlayerID FROM player WHERE RoomID = InRoomID AND AccountName = InAccountName);
        
			UPDATE player
            SET ClassName = Class
            WHERE PlayerID = @player;
        
			-- 	If someone else is currently on the tile which the player was on when they left then return a message to the caller
			IF ((SELECT COUNT(pt.PlayerID)
				FROM player_tile pt
                JOIN player p
					ON p.PlayerID = pt.PlayerID
						AND p.`Active` = 1
				WHERE TileID = (SELECT TileID
								FROM player_tile
								WHERE PlayerID = @player
									AND MovedOff IS NULL
								LIMIT 1)) > 0) AND ((SELECT TileID
													FROM player_tile
													WHERE PlayerID = @player
														AND MovedOff IS NULL
													LIMIT 1
													) NOT IN
													(SELECT TileID
													FROM tile
													WHERE XPos = 0
														AND YPos = 0
														AND RoomID = InRoomID)) THEN
                    SELECT 'Tile occupied';
			ELSE
				
                -- Reactivate the player on that tile
				UPDATE player
				SET `Active` = 1
				WHERE PlayerID = @player;
			
            END IF;
            
		-- Create a new player with the requested account on the requested room and place them on the tile at 0,0
        ELSE
			INSERT INTO player (CurrentEnergy, CurrentHealth, AccountName, RoomID, ClassName)
				VALUES (20, 20, InAccountName, InRoomID, Class);

			SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccountName AND RoomID = InRoomID);

			-- Create their starting ability instance
			INSERT INTO abilityinstance (AbilityName)
				VALUES ((SELECT AbilityName
						 FROM class c
						 JOIN player p
							ON p.ClassName = c.ClassName
						 WHERE p.PlayerID = @player)
						);
			
			-- Add ability to inventory
			INSERT INTO player_ability (PlayerID, AbilityID, PickedUp)
				VALUES (@player, (SELECT Get_Instance((SELECT AbilityName
														FROM class c
														JOIN player p
															ON p.ClassName = c.ClassName
														WHERE p.PlayerID = @player))), CURRENT_TIMESTAMP());

			CALL Attach_Player_Stat(@player, 'Strength');
			CALL Attach_Player_Stat(@player, 'Speed');
			CALL Attach_Player_Stat(@player, 'Energy');
			CALL Attach_Player_Stat(@player, 'Health');

			-- Places the player with the given account and room onto the tile with position 0,0 on the given table.
			INSERT INTO player_tile (TileID, PlayerID, MovedOn)
				VALUES (
						(SELECT TileID FROM tile WHERE RoomID = InRoomID AND XPos = 0 AND YPos = 0),
						(SELECT PlayerID FROM player WHERE AccountName = InAccountName AND RoomID = InRoomID),
						CURRENT_TIMESTAMP()
						);
		END IF;
                        
	END IF;

END//

-- Create the player statistic value
CREATE PROCEDURE Attach_Player_Stat (
	IN InPlayer INT,
    IN InStatName VARCHAR(16)
)
BEGIN

	-- Error: If the player doesn't exist
    IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = InPlayer) THEN
		SELECT 'Player not found' AS message;
	
    -- Error: If the stat link already exists
    ELSEIF EXISTS (SELECT * FROM player_stat WHERE StatName = InStatName AND PlayerID = InPlayer) THEN
		SELECT 'Link already exists' AS message;
    
	ELSE
    
		INSERT INTO player_stat (StatName, `Value`, PlayerID)
			VALUES (InStatName, (SELECT SUM(AmountSum) FROM (
															SELECT SUM(Amount) AS AmountSum
															FROM class_stat
															WHERE ClassName = (SELECT ClassName FROM player WHERE PlayerID = InPlayer)
																AND StatName = InStatName
															UNION
															SELECT SUM(Amount) AS AmountSum
															FROM statchange
															WHERE AbilityName IN (SELECT ai.AbilityName
																					FROM player_ability pa
																					JOIN abilityinstance ai
																						ON ai.AbilityID = pa.AbilityID
																					WHERE pa.PlayerID = InPlayer
																						AND pa.Dropped IS NULL)
																AND StatName = InStatName) AS st), InPlayer);

    END IF;

END//

-- Get all abilities in the player's inventory
CREATE PROCEDURE Get_Inventory (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

		-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
        
        SELECT a.*, ai.AbilityID
        FROM player_ability pa
        JOIN abilityinstance ai
			ON ai.AbilityID = pa.AbilityID
		JOIN ability a
			ON ai.AbilityName = a.AbilityName
        WHERE pa.PlayerID = @player
			AND pa.Dropped IS NULL;

    END IF;

END//

-- Find available movement tiles and move player
CREATE PROCEDURE Move_Player (
	IN InAccount VARCHAR(32),
    IN InRoom INT,
	IN MoveX INT,
    IN MoveY INT,
	IN SearchRadius INT,
    IN AllowDiagonal BIT
)
BEGIN

	DECLARE playerX INT;
	DECLARE playerY INT;

	-- Error: If requested radius is too small
    IF SearchRadius < 1 THEN
		SELECT 'Search radius too small' AS message;
	
		-- Error: If the account doesn't exist
    ELSEIF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
    -- Error: If tile is already occupied
    ELSEIF EXISTS (SELECT pt.PlayerID FROM player_tile pt JOIN player p ON p.PlayerID = pt.PlayerID WHERE pt.MovedOff IS NULL AND pt.TileID = (SELECT TileID FROM tile WHERE XPos = MoveX AND YPos = MoveY) AND p.`Active` = 1) THEN
		SELECT 'Tile already occupied' AS message;
    
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
        
		-- Get the player's current position
		SET @playerX = (SELECT XPos FROM tile WHERE TileID = (SELECT TileID FROM player_tile WHERE PlayerID = @player AND MovedOff IS NULL));
		SET @playerY = (SELECT YPos FROM tile WHERE TileID = (SELECT TileID FROM player_tile WHERE PlayerID = @player AND MovedOff IS NULL));
        
    	-- Error: If procedure tries to move diagonally without diagonal flag
		IF AllowDiagonal = 0 AND ((@playerX - MoveX) <> 0 AND (@playerY - MoveY) <> 0) THEN
				SELECT 'Diagonal movement on non-diagonal check' AS message;
                
		-- Error: Requested tile is out of range
		ELSEIF NOT EXISTS (WITH surroundingtiles AS 
			(
				SELECT *
				FROM tile
				WHERE XPos >= @playerX - searchRadius
					AND XPos <= @playerX + searchRadius
					AND YPos >= @playerY - searchRadius
					AND YPos <= @playerY + searchRadius
					AND RoomID = (SELECT RoomID
									FROM player
									WHERE PlayerID = @player)
			) SELECT TileID FROM surroundingtiles WHERE XPos = MoveX AND YPos = MoveY) THEN
			
            SELECT 'Tile out of range' AS message;
		
        -- Place the requested player on the requested tile and remove them from the previous tile
        ELSE
			UPDATE player_tile
            SET MovedOFF = CURRENT_TIMESTAMP()
            WHERE MovedOff IS NULL
				AND PlayerID = @player;
        
			INSERT INTO player_tile (TileID, PlayerID, MovedOn)
				VALUES ((SELECT TileID FROM tile WHERE XPos = MoveX AND YPos = MoveY), @player, CURRENT_TIMESTAMP());
                
		END IF;
        
	END IF;
    
END//

-- Glitch ability movement
CREATE PROCEDURE Glitch_Ability (
	IN InRoom INT
)
BEGIN

	DECLARE i INT DEFAULT 1;

	-- Error: If requested room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room does not exist' AS message;
    
    ELSE 
		-- Remove the requested ability instance from its tile and add it to the player's inventory
		
        DROP TEMPORARY TABLE IF EXISTS glitchabilities;
        
        CREATE TEMPORARY TABLE glitchabilities AS (SELECT ta.AbilityID
													FROM tile_ability ta
													JOIN abilityinstance ai
														ON ai.AbilityID = ta.AbilityID
													JOIN ability a
														ON a.AbilityName = ai.AbilityName
													JOIN tile t
														ON t.TileID = ta.TileID
													WHERE ta.Removed IS NULL
														AND a.Glitched = 1
														AND t.RoomID = InRoom);

        glitch_loop: LOOP
        
			IF i >= (SELECT COUNT(AbilityID) FROM glitchabilities) THEN
				LEAVE glitch_loop;
			END IF;
        
			SET @currentability = (SELECT AbilityID FROM glitchabilities LIMIT i, 1);
        
			UPDATE tile_ability
			SET Removed = CURRENT_TIMESTAMP()
			WHERE AbilityID = @currentability
				AND Removed IS NULL;
        
			INSERT INTO tile_ability (TileID, AbilityID, Placed)
				VALUE (Random_Tile(InRoom), @currentability, CURRENT_TIMESTAMP());
            
            SET i = i + 1;
            
        END LOOP glitch_loop;
		
        DROP TEMPORARY TABLE IF EXISTS glitchabilities;
        
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

-- Swapping item positions
CREATE PROCEDURE Transfer_Abilities(
	IN Item1 INT,
    IN Item2 INT,
    IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	CASE
    
		-- Error: If one of the requested ability instances doen't exist
		WHEN NOT EXISTS (SELECT * FROM abilityinstance WHERE AbilityID = Item1 OR AbilityID = Item2) THEN
			SELECT 'One or both ability instances not found' AS message;
		
        -- Error: If the account doesn't exist
        WHEN NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
			SELECT 'Account not found' AS message;
		
        -- Error: If the room doesn't exist
		WHEN NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
			SELECT 'Room not found' AS message;
		
		ELSE
		
			SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
		
			-- If the first ability is null
			IF Item1 = -1 THEN
			
				-- Error: If both abilities are null
				IF Item2 = -1 THEN
					SELECT 'No abilities to swap' AS message;
					
				ELSE
					-- If the second given ability is in the player's inventory
					IF EXISTS (SELECT * FROM player_ability WHERE AbilityID = Item2 AND Dropped IS NULL) THEN
						CALL Drop_Ability(@player, Item2);
						SELECT 'First selection was null, second was in player inventory' AS message;
						
					-- If the first ability is on a tile
					ELSEIF EXISTS (SELECT * FROM tile_ability WHERE AbilityID = Item2 AND Removed IS NULL) THEN
						CALL Pickup_Ability(@player, Item2);  
						SELECT 'First selection was null, second was in tile inventory' AS message;
					
					END IF;
					
				END IF;
			
			-- If only the second ability is null
			ELSEIF Item2 = -1 THEN
			
				-- If the first given ability is in the player's inventory
				IF EXISTS (SELECT * FROM player_ability WHERE AbilityID = Item1 AND Dropped IS NULL) THEN
					CALL Drop_Ability(@player, Item1);   
					SELECT 'Second selection was null, first was in player inventory' AS message;
				
				-- If the first ability is on a tile
				ELSEIF EXISTS (SELECT * FROM tile_ability WHERE AbilityID = Item1 AND Removed IS NULL) THEN
					CALL Pickup_Ability(@player, Item1);  
					SELECT 'Second selection was null, first was in tile inventory' AS message; 
				
				END IF;
			
			ELSEIF Item1 <> -1 AND Item2 <> -1 THEN
				-- If the first given ability is in the player's inventory
				IF EXISTS (SELECT * FROM player_ability WHERE AbilityID = Item1 AND Dropped IS NULL) THEN
				-- If the second given ability is not in the player's inventory
					IF EXISTS (SELECT * FROM tile_ability WHERE AbilityID = Item2 AND Removed IS NULL) THEN
						CALL Drop_Ability(@player, Item1);
						CALL Pickup_Ability(@player, Item2);
						SELECT 'Selection 1 in player inv, 2 in tile inventory' AS message;
					END IF;
				
				-- If the second given ability is in the player's inventory
				ELSEIF EXISTS (SELECT * FROM player_ability WHERE AbilityID = Item2 AND Dropped IS NULL) THEN
				-- If the first given ability is not in the player's inventory
					IF EXISTS (SELECT * FROM tile_ability WHERE AbilityID = Item1 AND Removed IS NULL) THEN
						CALL Drop_Ability(@player, Item2);
						CALL Pickup_Ability(@player, Item1);
						SELECT 'Selection 2 in player inv, 1 in tile inventory' AS message;
					END IF;
				
				END IF;
				
			ELSE
             
				SELECT 'Missed All Checks' AS message; 
            
			END IF; 

	END CASE;

END//

-- Player acquiring inventory
CREATE PROCEDURE Pickup_Ability (
	IN Player INT,
    IN AbilityInstance INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player AND `Active` = 1) THEN
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
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = Player AND `Active` = 1) THEN
		SELECT 'Invalid player' AS message;
    
    -- Error: If requested ability instance doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM abilityinstance WHERE abilityID = AbilityInstance) THEN
		SELECT 'Invalid ability instance' AS message;
    
    -- Error: If player isn't holding ability
    ELSEIF NOT EXISTS (SELECT * FROM player_ability WHERE AbilityID = AbilityInstance AND PlayerID = Player AND Dropped IS NULL) THEN
		SELECT 'Player is not holding that ability' AS message;
    
    -- Remove the requested item from its current tile and add it to the player's inventory
    ELSE
        IF NOT EXISTS (SELECT * FROM tile_ability WHERE Placed = CURRENT_TIMESTAMP() AND AbilityID = AbilityInstance) THEN
			UPDATE player_ability
				SET Dropped = CURRENT_TIMESTAMP()
				WHERE AbilityID = AbilityInstance
					AND Dropped IS NULL;
		
			INSERT INTO tile_ability (TileID, AbilityID, Placed)
				VALUES ((SELECT TileID FROM player_tile WHERE PlayerID = Player AND MovedOff IS NULL), AbilityInstance, CURRENT_TIMESTAMP());
			
            CALL Update_Score(Player);
            
		END IF;
        
    END IF;
    
END//

-- Update score
CREATE PROCEDURE Update_Score (
	IN InPlayer INT
)
BEGIN

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = InPlayer AND `Active` = 1) THEN
		SELECT 'Invalid player id' AS message;

	-- Default: If there is nothing in the inventory score is just the battle score
    ELSEIF NOT EXISTS (SELECT * FROM player_ability WHERE PlayerID = InPlayer AND Dropped IS NULL) THEN
		SET @newscore = (SELECT BattleScore FROM player WHERE PlayerID = InPlayer);
        
        UPDATE player
			SET CurrentScore = @newscore
			WHERE PlayerID = InPlayer;
	
    -- Set the player's score to the sum of the values of all abilities they are currently holding plus their battle score
    ELSE
		SET @newscore = ( SELECT SUM(a.`Value`) + p.BattleScore
							FROM player p
							JOIN player_ability pa
								ON p.PlayerID = pa.PlayerID
							JOIN abilityinstance ai
								ON pa.AbilityID = ai.AbilityID
							JOIN ability a
								ON ai.AbilityName = a.AbilityName
							WHERE pa.Dropped IS NULL
							GROUP BY p.PlayerID
								HAVING p.PlayerID = InPlayer
						);
                                  
		UPDATE player
			SET CurrentScore = @newscore
			WHERE PlayerID = InPlayer;
	END IF;
    
    -- Update the high score if necessary
    IF (SELECT CurrentScore FROM player WHERE PlayerID = InPlayer) > (SELECT HighScore FROM player WHERE PlayerID = InPlayer) THEN
		UPDATE player
        SET HighScore = CurrentScore
        WHERE PlayerID = InPlayer;
	END IF;

END//

-- Get score
CREATE FUNCTION Get_Score ( InAccountName VARCHAR(32), Room INT )
RETURNS INT DETERMINISTIC
BEGIN

	-- Default: If requested player doesn't exist return 0
	IF NOT EXISTS (SELECT CurrentScore FROM player WHERE AccountName = InAccountName AND RoomID = Room) THEN
		RETURN 0;
	END IF;

	-- Return the player's current score value
	RETURN (SELECT CurrentScore FROM player WHERE AccountName = InAccountName AND RoomID = Room);
    
END//

-- Get leaderboard
CREATE PROCEDURE Get_Leaderboard(
	IN Room INT
)
BEGIN

	-- Error: If requested room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Invalid room' AS message;

	-- Get the player names and high scores from the requested room
	ELSE
		SELECT AccountName, HighScore FROM player WHERE RoomID = Room;
	END IF;

END//

-- Get all the abilities on the given x/y range around the player
CREATE PROCEDURE Get_Tile_Inventory (
	IN InAccount VARCHAR(32),
    IN InRoom INT,
    IN InXRange INT,
    IN InYRange INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
	-- Error: If the x or y range is not possible
    ELSEIF InXRange < 0 OR InYRange < 0 THEN
		SELECT 'Invalid search range' AS message;
    
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
        
		SET @playerx = (SELECT XPos 
						FROM tile t
                        JOIN player_tile pt
							ON pt.TileID = t.TileID
								AND pt.MovedOff IS NULL
						JOIN player p
							ON p.PlayerID = pt.PlayerID
						WHERE p.PlayerID = @player);
                        
		SET @playery = (SELECT YPos 
						FROM tile t
                        JOIN player_tile pt
							ON pt.TileID = t.TileID
								AND pt.MovedOff IS NULL
						JOIN player p
							ON p.PlayerID = pt.PlayerID
						WHERE p.PlayerID = @player);
    
		SELECT a.*, ai.AbilityID
        FROM tile_ability ta
        JOIN abilityinstance ai
			ON ai.AbilityID = ta.AbilityID
        JOIN ability a
			ON a.AbilityName = ai.AbilityName
		JOIN tile t
			ON ta.TileID = t.TileID
		WHERE ta.Removed IS NULL
			AND (
				(t.XPos <= @playerx + InXRange
				AND t.XPos >= @playerx - InXRange)
                AND
                (t.YPos <= @playery + InYRange
                AND t.YPos >= @playery - InYRange));

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
			SET `Admin`= IsAdmin,
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
		SELECT 'Account deletion cancelled' AS message;
    
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
    IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		INSERT INTO message (PlayerID, `Text`, SendTime)
			VALUES (@player, Message, CURRENT_TIMESTAMP());
	
    END IF;

END//

-- Read Messages
CREATE PROCEDURE Get_Messages(
	IN Room INT
)
BEGIN

	-- Error: If the room doesn't exist
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = Room) THEN
		SELECT 'Invalid room' AS message;
        
	ELSE
		SELECT p.AccountName, m.`Text`
		FROM message m
        JOIN player p
			ON p.PlayerID = m.PlayerID
        WHERE p.RoomID = Room
        ORDER BY m.SendTime;
        
	END IF;

END//

-- Update Player Data
CREATE PROCEDURE Update_Player (
	IN InAccount VARCHAR(32),
	IN Room INT,
    IN Score_Current INT,
    IN Score_High INT
)
BEGIN

	SET @player = (SELECT PlayerID FROM player WHERE RoomID = Room AND AccountName = InAccount);

	-- Error: If requested player doesn't exist
	IF NOT EXISTS (SELECT * FROM player WHERE PlayerID = @player) THEN
		SELECT 'Player does not exist' AS message;
    
    -- Update the requested player with the given data
    ELSE
		UPDATE `player`
			SET HighScore = Score_High,
				CurrentScore = Score_Current
			WHERE PlayerID = @player;
		
	END IF;

END//

-- Engage Combat
CREATE PROCEDURE Engage_Combat(
	IN InAccount VARCHAR(32),
    IN InRoom INT,
    IN Target INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	-- Error: If Player 1 or 2 don't exist
    ELSEIF NOT EXISTS (SELECT * FROM player WHERE ((AccountName = InAccount AND RoomID = InRoom) OR PlayerID = Target) AND `Active` = 1) THEN
		SELECT 'Invalid player(s)' AS message;
    
	-- Error: If Player 1 or 2 is already engaged
    ELSEIF NOT EXISTS (SELECT * FROM player WHERE ((AccountName = InAccount AND RoomID = InRoom) OR PlayerID = Target) AND Combatant IS NULL) THEN
		SELECT 'Player(s) already engaged' AS message;
    
    -- Error: If Player 1 and Player 2 are the same player
    ELSEIF (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom) = Target THEN
		SELECT 'Identical player' AS message;
    
    -- Error: If Player 1 and Player 2 are not in the same room
    ELSEIF (SELECT RoomID FROM player WHERE AccountName = InAccount AND RoomID = InRoom) <> (SELECT RoomID FROM player WHERE PlayerID = Target) THEN
		SELECT 'Players are in different rooms' AS message;
    
	-- Error: If Player 1 and Player 2 are too many tiles apart    
    ELSEIF ABS((SELECT t.XPos + t.YPos FROM tile t JOIN player_tile pt ON pt.TileID = t.TileID JOIN player p ON p.PlayerID = pt.PlayerID WHERE p.AccountName = InAccount AND p.RoomID = InRoom AND pt.MovedOff IS NULL) - (SELECT t.XPos + t.YPos FROM tile t JOIN player_tile pt ON pt.TileID = t.TileID WHERE pt.PlayerID = Target AND pt.MovedOff IS NULL)) <> 1 THEN
		SELECT 'Players too far apart' AS message;
    
    -- Set each other as combatants
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		UPDATE player
        SET Combatant = CASE
			WHEN PlayerID = @player THEN Target
            WHEN PlayerID = Target THEN @player
            END;

	END IF;

END//

-- Disengage Combat
CREATE PROCEDURE Disengage_Combat(
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	-- Error: If player doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM player WHERE AccountName = InAccount AND RoomID = InRoom AND `Active` = 1) THEN
		SELECT 'Invalid player' AS message;

	-- Error: If player is not in combat
	ELSEIF (SELECT Combatant FROM player WHERE AccountName = InAccount AND RoomID = InRoom) IS NULL THEN
		SELECT 'Player not in combat' AS messsage;

	-- Set both player's combatant to null
	ELSE 
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
		SET @otherplayer = (SELECT Combatant FROM player WHERE PlayerID = @player);
        
		UPDATE player
        SET Combatant = NULL
        WHERE PlayerID = @player
			OR PlayerID = @otherplayer;  

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
						(SELECT `Value` FROM player_stat WHERE StatName = 'Strength' AND PlayerID = @attacker) +
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
    IF NOT EXISTS (SELECT * FROM player WHERE (PlayerID = Winner OR PlayerID = Loser) AND `Active` = 1) THEN
		SELECT 'Player(s) do not exist' AS message;

	ELSE
		SET @scoreincrease = CEIL((SELECT CurrentScore FROM player WHERE PlayerID = Loser) / 10) + (SELECT SUM(`Value`) FROM player_stat WHERE PlayerID = Loser);
    
		-- Add score increase to winner's battle score and reset the loser's battle score
		UPDATE player
		SET BattleScore = CASE
			WHEN PlayerID = Winner THEN BattleScore + @scoreincrease
			WHEN PlayerID = Loser THEN 0
            END;

		-- Reset the loser's health
        UPDATE player
        SET CurrentHealth = 20
		WHERE PlayerID = Loser;
    
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
        UPDATE player_tile
        SET MovedOff = CURRENT_TIMESTAMP()
        WHERE MovedOff IS NULL
			AND PlayerID = Loser;
        
		INSERT INTO player_tile (PlayerID, TileID, MovedOn)
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
RETURNS INT DETERMINISTIC
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

-- Exiting room
CREATE PROCEDURE Exit_Room (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN
	
	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
    
    -- Change player active status
    ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		IF (SELECT Combatant FROM player WHERE PlayerID = @player) IS NOT NULL THEN
			CALL Disengage_Combat((SELECT AccountName FROM player WHERE PlayerID = @player), (SELECT RoomID FROM player WHERE PlayerID = @player));
        END IF;
    
		UPDATE player
		SET `Active` = 0
        WHERE PlayerID = @player;
    
    END IF;

END//

-- Rejoin at a new location
CREATE PROCEDURE Rejoin_At (
	IN NewLocation INT,
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN
	
	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	-- Error: If tile does not exist
    ELSEIF NOT EXISTS (SELECT * FROM tile WHERE TileID = NewLocation) THEN
		SELECT 'Tile does not exist' AS message;
    
    -- Error: If the player has not been in the given room before
    ELSEIF NOT EXISTS (SELECT * FROM player WHERE AccountName = InAccount AND RoomID = InRoom)THEN
		SELECT 'Player has not joined room' AS message;
        
    -- Error: If the player is active
    ELSEIF (SELECT `active` FROM player WHERE AccountName = InAccount AND RoomID = InRoom) = 1 THEN
		SELECT 'Player already in game' AS message;
    
    -- Error: If tile is not in player's room
    ELSEIF (SELECT RoomID FROM tile WHERE TileID = NewLocation) <> (SELECT RoomID FROM player WHERE AccountName = InAccount AND RoomID = InRoom) THEN
		SELECT 'Tile not in players room' AS message;
    
    -- Error: If tile is occupied
    ELSEIF (SELECT COUNT(pt.PlayerID)
				FROM player_tile pt
                JOIN player p
					ON p.PlayerID = pt.PlayerID
						AND p.`Active` = 1
				WHERE pt.TileID = NewLocation
					AND MovedOff IS NULL) > 0 THEN
		SELECT 'Tile already occupied' AS message;
    
    -- Move player to tile and reactivate them
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		UPDATE player_tile
        SET MovedOff = CURRENT_TIMESTAMP()
        WHERE MovedOff IS NULL
			AND PlayerID = @player;
        
		INSERT INTO player_tile (PlayerID, TileID, MovedOn)
			VALUES (@player, NewLocation, CURRENT_TIMESTAMP());
            
        UPDATE player
        SET `Active` = 1
        WHERE PlayerID = @player;
    
    END IF;
    
END//

-- Get all rooms in the database and their player counts
CREATE PROCEDURE Get_Rooms ()
BEGIN

	SELECT r.RoomID, r.RoomName, COUNT(p.PlayerID) AS PlayerCount
    FROM room r
    LEFT JOIN player p
		ON p.RoomID = r.RoomID
			AND p.`Active` = 1
	GROUP BY r.RoomID, r.RoomName;

END//

-- Get all the rooms owned by a specific account
CREATE PROCEDURE Get_Owned_Rooms (
	IN `User` VARCHAR(32)
)
BEGIN
	
    -- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = `User`) THEN
		SELECT 'Account not found';
	ELSE
		SELECT r.RoomID, r.RoomName, COUNT(p.PlayerID) AS PlayerCount
        FROM room r
		LEFT JOIN player p
			ON p.RoomID = r.RoomID
				AND p.`Active` = 1
        WHERE r.AccountName = `User`
		GROUP BY r.RoomID, r.RoomName;
        
	END IF;
    
END//

-- Get the basic details about a given room
CREATE PROCEDURE Get_Room (
	IN room INT
)
BEGIN
	
    -- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM room WHERE RoomID = room) THEN
		SELECT 'Room not found';
	ELSE
		SELECT RoomName, p.AccountName
        FROM room r
		LEFT JOIN player p
			ON p.RoomID = r.RoomID
        WHERE r.RoomID = room
        ORDER BY HighScore
        LIMIT 1;
        
	END IF;
    
END//

-- Get all players in the database and what room they are in
CREATE PROCEDURE Get_Players ()
BEGIN

	SELECT p.AccountName, r.RoomName, r.RoomID
    FROM player p
	JOIN room r
	ON p.RoomID = r.RoomID;

END//

-- Get the details of a specific player in the database
CREATE PROCEDURE Get_Player (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SELECT r.RoomName, p.AccountName, p.HighScore, p.CurrentScore, p.CurrentEnergy, p.CurrentHealth, t.XPos, t.YPos
		FROM player p
		LEFT JOIN room r
			ON r.RoomID = p.RoomID
		LEFT JOIN player_tile pt
			ON pt.PlayerID = p.PlayerID
				AND pt.MovedOff IS NULL
		LEFT JOIN tile t
			ON t.TileID = pt.TileID
		WHERE p.AccountName = InAccount
			AND r.RoomID = InRoom;
	
    END IF;

END//

-- Get the stats for a specific player
CREATE PROCEDURE Get_Statistics (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
        
		SELECT StatName, `Value`
        FROM player_stat
        WHERE PlayerID = @player;
	
    END IF;

END//

-- Remove a given player from the database
CREATE PROCEDURE Delete_Player (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
	ELSE
		DELETE FROM player WHERE AccountName = InAccount AND RoomID = InRoom;

    END IF;

END//

-- Get all of the tiles around a player in a specified radius
CREATE PROCEDURE Get_Map_Snapshot (
	IN InAccount VARCHAR(32),
    IN InRoom INT,
    IN InRadius INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
    -- Error: If the radius is invalid
	ELSEIF InRadius < 0 THEN
		SELECT 'Radius too small' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		WITH player_position(PlayerX, PlayerY) AS (
			SELECT t.XPos, t.YPos
			FROM tile t
			JOIN player_tile pt
				ON t.TileID = pt.TileID
			WHERE pt.PlayerID = @player
				AND pt.MovedOff IS NULL
        )
		SELECT t.XPos, t.YPos, c.Sprite, p.AccountName, p.Combatant, p.PlayerID
        FROM tile t
        LEFT JOIN player_tile pt
			ON pt.TileID = t.TileID
				AND pt.MovedOff IS NULL
		LEFT JOIN player p
			ON p.PlayerID = pt.PlayerID
				AND p.`Active` = 1
		LEFT JOIN class c
			ON c.ClassName = p.ClassName
        WHERE t.RoomID = InRoom
			AND (p.`Active` <> 0
				OR p.`Active` IS NULL)
			AND (
					(t.XPos <= ((SELECT PlayerX FROM player_position) + InRadius)
						AND t.XPos >= ((SELECT PlayerX FROM player_position) - InRadius))
				AND
					(t.YPos <= ((SELECT PlayerY FROM player_position) + InRadius)
						AND t.YPos >= ((SELECT PlayerY FROM player_position) - InRadius))
				);

    END IF;
    
END//

-- Get the current energy value of a given player
CREATE PROCEDURE Get_Player_Energy (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		SELECT CurrentEnergy
        FROM player
        WHERE PlayerID = @player;
        
    END IF;
	
END//

-- Increase the given player's energy by a set value
CREATE PROCEDURE Replenish_Energy (
	IN InAccount VARCHAR(32),
    IN InRoom INT
)
BEGIN

	-- Error: If the account doesn't exist
    IF NOT EXISTS (SELECT * FROM `account` WHERE AccountName = InAccount) THEN
		SELECT 'Account not found' AS message;
    
    -- Error: If the room doesn't exist
	ELSEIF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
        
	ELSE
		SET @player = (SELECT PlayerID FROM player WHERE AccountName = InAccount AND RoomID = InRoom);
    
		UPDATE player
        SET CurrentEnergy = CurrentEnergy + 1
        WHERE PlayerID = @player
			AND CurrentEnergy < 20;
        
        UPDATE player
        SET CurrentHealth = CurrentHealth + 1
        WHERE PlayerID = @player
			AND CurrentHealth < 20;
        
    END IF;
	
END//

-- Get the first active player from a room
CREATE PROCEDURE Get_Primary_Player (
	IN InRoom INT
)
BEGIN

	-- Error: If the room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
    ELSE
		SELECT a.AccountName
        FROM `account` a
        JOIN player p
			ON p.AccountName = a.AccountName
		WHERE p.`active` = 1
        LIMIT 1;
	
    END IF;

END//

-- Get a list of all unoccupied tiles in a room
CREATE PROCEDURE Get_Available_Tiles (
	IN InRoom INT
)
BEGIN

	-- Error: If the room doesn't exist
	IF NOT EXISTS (SELECT * FROM room WHERE RoomID = InRoom) THEN
		SELECT 'Room not found' AS message;
	
    ELSE
		SELECT XPos, YPos, TileID
        FROM tile
        WHERE RoomID = InRoom
			AND TileID NOT IN (
								SELECT TileID
								FROM player_tile
								WHERE MovedOff IS NULL
								);
		
    END IF;

END//

DELIMITER ;

CALL Generate_Database();
CALL Create_Test_Data();
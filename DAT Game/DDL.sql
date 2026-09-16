DROP DATABASE IF EXISTS gamedb;
CREATE DATABASE gamedb;
USE gamedb;

DELIMITER //

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

	CREATE TABLE player (
		PlayerID INT AUTO_INCREMENT,
		CurrentScore INT NOT NULL DEFAULT 0,
		HighScore INT NOT NULL DEFAULT 0,
		CurrentEnergy INT NOT NULL,
		CurrentHealth INT NOT NULL,
		AccountName VARCHAR(32) NOT NULL,
		RoomID INT NOT NULL,
		Sprite VARCHAR(32) NOT NULL,
		PRIMARY KEY (PlayerID),
		CONSTRAINT fk_player_account
			FOREIGN KEY (AccountName)
			REFERENCES `account`(AccountName)
            ON DELETE CASCADE,
		CONSTRAINT fk_player_room
			FOREIGN KEY (RoomID)
			REFERENCES room(RoomID)
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

	CREATE TABLE message (
		PlayerID INT,
		SendTime TIMESTAMP,
		`Text` VARCHAR(128) NOT NULL,
		PRIMARY KEY (PlayerID, SendTime),
		CONSTRAINT fk_message_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID)
            ON DELETE CASCADE
	);

	CREATE TABLE stat (
		StatName VARCHAR(16),
		`MaxValue` INT NOT NULL,
		PRIMARY KEY (StatName)
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
	);

	CREATE TABLE player_stat (
		StatName VARCHAR(16),
		PlayerID INT,
		`Value` INT NOT NULL,
		PRIMARY KEY (StatName, PlayerID),
		CONSTRAINT fk_playerstat_player
			FOREIGN KEY (PlayerID)
			REFERENCES player(PlayerID),
		CONSTRAINT fk_playerstat_stat
			FOREIGN KEY (StatName)
			REFERENCES stat(StatName)
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
		`Timestamp` TIMESTAMP,
		PRIMARY KEY (TileID, PlayerID, `Timestamp`),
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
        
END //

CREATE PROCEDURE Create_Test_Data ()
BEGIN
	INSERT INTO `account` (AccountName, `Password`, `Admin`)
		VALUES 
		('John', 'Password123', 1),
		('Amanda', 'HelloWorld', 0),
		('Test', 'TestTest', 0),
		('Ghostie', 'eits0hg', 1),
		('V', 'V3nd3774', 0)
	;

	INSERT INTO room (RoomName, AccountName)
		VALUES ('Test Room', 'Ghostie');

	INSERT INTO player (CurrentEnergy, CurrentHealth, AccountName, RoomID, Sprite)
		VALUES
		(10, 10, 'Ghostie', 1, './Player.png')
	;

	INSERT INTO tile ( XPos, YPos, RoomID)
		VALUES
		(0, 0, 1),
		(1, 1, 1),
		(1, 2, 1),
		(2, 1, 1)
	;

	INSERT INTO ability (AbilityName, `Description`, `Value`, Cost, Combat, Damage, Sprite)
		VALUES
		('Teleport', 'Move instantly to a different unoccupied tile.', 15, 6, 0, 0, './Ability.png'),
		('Overtightened Spring', 'A spring that has somehow been tighened past its normal breaking point.', 8, 0, 0, 0, './Ability.png'),
		('Piston Wreck', 'Use the pistons in your suit to hit a target even harder.', 1, 1, 1, 5, './Ability.png'),
		('Hyper-Shift', 'A gearshift that can switch between gears with minimal slowdown.', 10, 0, 0, 0, './Ability.png')
	;

	INSERT INTO abilityinstance (AbilityName)
		VALUES
        ('Teleport'),
        ('Overtightened Spring'),
        ('Piston Wreck'),
        ('Hyper-Shift')
	;

	INSERT INTO message (PlayerID, SendTime, Text)
		VALUES
		(1, '2026-12-31 12:00:00', 'Hello World!'),
		(1, '2026-12-31 12:01:00', 'Is this thing on?')
	;

	INSERT INTO stat (StatName, `MaxValue`)
		VALUES
		('Health', 200),
		('Energy', 60),
		('Speed', 50),
		('Strength', 100)
	;

	INSERT INTO statchange (AbilityName, StatName, Amount)
		VALUES
		('Overtightened Spring', 'Speed', 5),
		('Overtightened Spring', 'Health', -5),
		('Hyper-Shift', 'Speed', 10)
	;

	INSERT INTO player_stat (StatName, PlayerID, `Value`)
		VALUES
		('Health', 1, 5),
		('Energy', 1, 2),
		('Speed', 1, 6),
		('Strength', 1, 4)
	;

	INSERT INTO player_ability (PickedUp, AbilityID, PlayerID, Dropped)
		VALUES
		('2026-12-31 12:00:00', 1, 1, NULL),
		('2026-12-31 11:00:00', 2, 1, '2026-12-31 12:00:00')
	;

	INSERT INTO player_tile (TileID, PlayerID, `Timestamp`)
		VALUES
		(1, 1, '2026-12-31 11:00:00'),
		(2, 1, '2026-12-31 11:01:00'),
		(1, 1, '2026-12-31 11:02:00')
	;

	INSERT INTO tile_ability (Placed, TileID, AbilityID)
		VALUES
		('2026-12-31 10:00:00', 2, 1),
		('2026-12-31 10:00:00', 1, 2)
	;
END //

CREATE PROCEDURE Fetch_Users()
BEGIN
	SELECT * FROM `account`;
END//

CREATE PROCEDURE Fetch_Tiles()
BEGIN
	SELECT * FROM tile;
END//

CREATE PROCEDURE Fetch_Rooms()
BEGIN
	SELECT * FROM room;
END//


DELIMITER ;

CALL Generate_Database();
-- CALL Create_Test_Data();
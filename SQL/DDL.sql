DROP DATABASE IF EXISTS gamedb;
CREATE DATABASE gamedb;
USE gamedb;

DELIMITER //

CREATE PROCEDURE `Generate_Database`()
BEGIN
	CREATE TABLE `account` (
		`AccountName` VARCHAR(32),
		`Password` VARCHAR(32) NOT NULL,
		`Admin` BIT NOT NULL DEFAULT 0,
		`Locked` BIT NOT NULL DEFAULT 0,
		`LoginAttempts` INT(1) NOT NULL DEFAULT 0,
		PRIMARY KEY (`AccountName`)
	);

	CREATE TABLE `room` (
		`RoomID` INT AUTO_INCREMENT,
		`RoomName` VARCHAR(32) NOT NULL,
		PRIMARY KEY (`RoomID`)
	);

	CREATE TABLE `player` (
		`PlayerID` INT AUTO_INCREMENT,
		`CurrentScore` INT NOT NULL DEFAULT 0,
		`HighScore` INT NOT NULL DEFAULT 0,
		`CurrentEnergy` INT NOT NULL,
		`CurrentHealth` INT NOT NULL,
		`AccountName` VARCHAR(32) NOT NULL,
		`RoomID` INT NOT NULL,
		`Sprite` VARCHAR(32) NOT NULL,
		PRIMARY KEY (`PlayerID`),
		CONSTRAINT fk_player_account
			FOREIGN KEY (`AccountName`)
			REFERENCES `account`(`AccountName`),
		CONSTRAINT fk_player_room
			FOREIGN KEY (`RoomID`)
			REFERENCES `room`(`RoomID`)
	);

	CREATE TABLE `tile` (
		`TileID` INT AUTO_INCREMENT,
		`XPos` INT NOT NULL,
		`YPos` INT NOT NULL,
		`RoomID` INT NOT NULL,
		PRIMARY KEY (`TileID`),
		CONSTRAINT fk_tile_room
			FOREIGN KEY (`RoomID`)
			REFERENCES `room`(`RoomID`)
	);

	CREATE TABLE `ability` (
		`AbilityID` INT AUTO_INCREMENT,
		`AbilityName` VARCHAR(24) NOT NULL,
		`Description` VARCHAR(255) NOT NULL,
		`Value` INT(5) NOT NULL,
		`Cost` INT(5) NOT NULL,
		`Combat` BIT NOT NULL,
		`Damage` INT(3),
		`Glitched` BIT NOT NULL DEFAULT 0,
		`Sprite` VARCHAR(32) NOT NULL,
		PRIMARY KEY (`AbilityID`)
	);

	CREATE TABLE `message` (
		`PlayerID` INT,
		`SendTime` TIMESTAMP,
		`Text` VARCHAR(128) NOT NULL,
		PRIMARY KEY (`PlayerID`, `SendTime`),
		CONSTRAINT fk_message_player
			FOREIGN KEY (`PlayerID`)
			REFERENCES `player`(`PlayerID`)
	);

	CREATE TABLE `stat` (
		`StatName` VARCHAR(16),
		`MaxValue` INT NOT NULL,
		PRIMARY KEY (`StatName`)
	);

	CREATE TABLE `statchange` (
		`AbilityID` INT,
		`StatName` VARCHAR(16),
		`Amount` INT(2) NOT NULL,
		PRIMARY KEY (`AbilityID`, `StatName`),
		CONSTRAINT fk_statchange_ability
			FOREIGN KEY (`AbilityID`)
			REFERENCES `ability`(`AbilityID`),
		CONSTRAINT fk_statchange_stat
			FOREIGN KEY (`StatName`)
			REFERENCES `stat`(`StatName`)
	);

	CREATE TABLE `player_stat` (
		`StatName` VARCHAR(16),
		`PlayerID` INT,
		`Value` INT NOT NULL,
		PRIMARY KEY (`StatName`, `PlayerID`),
		CONSTRAINT fk_playerstat_player
			FOREIGN KEY (`PlayerID`)
			REFERENCES `player`(`PlayerID`),
		CONSTRAINT fk_playerstat_stat
			FOREIGN KEY (`StatName`)
			REFERENCES `stat`(`StatName`)
	);

	CREATE TABLE `player_ability` (
		`PickedUp` TIMESTAMP,
		`AbilityID` INT,
		`PlayerID` INT,
		`Dropped` TIMESTAMP,
		PRIMARY KEY (`PickedUp`, `AbilityID`, `PlayerID`),
		CONSTRAINT fk_playerability_ability
			FOREIGN KEY (`AbilityID`)
			REFERENCES `ability`(`AbilityID`),
		CONSTRAINT fk_playerability_player
			FOREIGN KEY (`PlayerID`)
			REFERENCES `player`(`PlayerID`)
	);

	CREATE TABLE `player_tile` (
		`TileID` INT,
		`PlayerID` INT,
		`Timestamp` TIMESTAMP,
		PRIMARY KEY (`TileID`, `PlayerID`, `Timestamp`),
		CONSTRAINT fk_playertile_player
			FOREIGN KEY (`PlayerID`)
			REFERENCES `player`(`PlayerID`),
		CONSTRAINT fk_playertile_tile
			FOREIGN KEY (`TileID`)
			REFERENCES `tile`(`TileID`)
	);

	CREATE TABLE `tile_ability` (
		`Timestamp` TIMESTAMP,
		`TileID` INT,
		`AbilityID` INT NOT NULL,
		PRIMARY KEY (`Timestamp`, `TileID`),
		CONSTRAINT fk_tileability_tile
			FOREIGN KEY (`TileID`)
			REFERENCES `tile`(`TileID`),
		CONSTRAINT fk_tileability_ability
			FOREIGN KEY (`AbilityID`)
			REFERENCES `ability`(`AbilityID`)
	);

	INSERT INTO `account` (`AccountName`, `Password`, `Admin`)
		VALUES 
		('John', 'Password123', 1),
		('Amanda', 'HelloWorld', 0),
		('Test', 'TestTest', 0),
		('Ghostie', 'eits0hg', 1),
		('V', 'V3nd3774', 0)
	;

	INSERT INTO `room` (`RoomName`)
		VALUES ('Test Room');

	INSERT INTO `player` (`CurrentEnergy`, `CurrentHealth`, `AccountName`, `RoomID`, `Sprite`)
		VALUES
		(10, 10, 'Ghostie', 1, './Player.png')
	;

	INSERT INTO `tile` ( `XPos`, `YPos`, `RoomID`)
		VALUES
		(0, 0, 1),
		(1, 1, 1),
		(1, 2, 1),
		(2, 1, 1)
	;

	INSERT INTO `ability` (`AbilityName`, `Description`, `Value`, `Cost`, `Combat`, `Damage`, `Sprite`)
		VALUES
		('Teleport', 'Move instantly to a different unoccupied tile.', 15, 6, 0, 0, './Ability.png'),
		('Overtightened Spring', 'A spring that has somehow been tighened past its normal breaking point.', 8, 0, 0, 0, './Ability.png'),
		('Piston Wreck', 'Use the pistons in your suit to hit a target even harder.', 1, 1, 1, 5, './Ability.png'),
		('Hyper-Shift', 'A gearshift that can switch between gears with minimal slowdown.', 10, 0, 0, 0, './Ability.png')
	;

	INSERT INTO `message` (`PlayerID`, `SendTime`, `Text`)
		VALUES
		(1, '2026-12-31 12:00:00', 'Hello World!'),
		(1, '2026-12-31 12:01:00', 'Is this thing on?')
	;

	INSERT INTO `stat` (`StatName`, `MaxValue`)
		VALUES
		('Health', 200),
		('Energy', 60),
		('Speed', 50),
		('Strength', 100)
	;

	INSERT INTO `statchange` (`AbilityID`, `StatName`, `Amount`)
		VALUES
		(1, 'Speed', 5),
		(1, 'Health', -5),
		(2, 'Speed', 10)
	;

	INSERT INTO `player_stat` (`StatName`, `PlayerID`, `Value`)
		VALUES
		('Health', 1, 5),
		('Energy', 1, 2),
		('Speed', 1, 6),
		('Strength', 1, 4)
	;

	INSERT INTO `player_ability` (`PickedUp`, `AbilityID`, `PlayerID`, `Dropped`)
		VALUES
		('2026-12-31 12:00:00', 1, 1, NULL),
		('2026-12-31 11:00:00', 2, 1, '2026-12-31 12:00:00')
	;

	INSERT INTO `player_tile` (`TileID`, `PlayerID`, `Timestamp`)
		VALUES
		(1, 1, '2026-12-31 11:00:00'),
		(2, 1, '2026-12-31 11:01:00'),
		(1, 1, '2026-12-31 11:02:00')
	;

	INSERT INTO `tile_ability` (`Timestamp`, `TileID`, `AbilityID`)
		VALUES
		('2026-12-31 10:00:00', 2, 1),
		('2026-12-31 10:00:00', 1, 2)
	;

END //

DELIMITER ;

CALL `Generate_Database`();
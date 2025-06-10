-- Create the database with charset and collation
CREATE DATABASE IF NOT EXISTS ipm_bidding_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the database
USE ipm_bidding_system;

-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- CREATE TABLE IF NOT EXISTS TimeSlot
DROP TABLE IF EXISTS `TimeSlot`;
CREATE TABLE IF NOT EXISTS `TimeSlot` (
	timeSlotId INT PRIMARY KEY AUTO_INCREMENT,
	timeSlotStartTime DATETIME,
	timeSlotEndTime DATETIME,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Location
DROP TABLE IF EXISTS `Location`;
CREATE TABLE IF NOT EXISTS `Location` (
	locationId INT PRIMARY KEY AUTO_INCREMENT,
	locationCountry VARCHAR(30),
	locationCity VARCHAR(25),
	locationAddress VARCHAR(60),
	locationPostalCode VARCHAR(10),
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Organization
DROP TABLE IF EXISTS `Organization`;
CREATE TABLE IF NOT EXISTS `Organization` (
	organizationId INT PRIMARY KEY AUTO_INCREMENT, 
	organizationName VARCHAR(50) NOT NULL, 
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Person
DROP TABLE IF EXISTS `Person`;
CREATE TABLE IF NOT EXISTS `Person` (
	personID INT PRIMARY KEY AUTO_INCREMENT,
	personName VARCHAR(30) NOT NULL,
	personEmail VARCHAR(30) NOT NULL,
	personBirthDate DATE NOT NULL,
	personNIF INT NOT NULL,
	personGender SET('male', 'female', 'other'),
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Participant
DROP TABLE IF EXISTS `Participant`;
CREATE TABLE IF NOT EXISTS `Participant` (
	participantID INT PRIMARY KEY AUTO_INCREMENT,
	person_personID INT NOT NULL UNIQUE,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (person_personID) REFERENCES Person (personID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS ParticipantSession
DROP TABLE IF EXISTS `ParticipantSession`;
CREATE TABLE IF NOT EXISTS `ParticipantSession` (
	participant_participantID INT NOT NULL,
	session_sessionId INT NOT NULL,
	PRIMARY KEY (participant_participantID, session_sessionId),
	FOREIGN KEY (participant_participantID) REFERENCES Participant (participantID),
	FOREIGN KEY (session_sessionId) REFERENCES `Session` (sessionId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Auctioneer
DROP TABLE IF EXISTS `Auctioneer`;
CREATE TABLE IF NOT EXISTS `Auctioneer` (
	auctioneerId INT PRIMARY KEY AUTO_INCREMENT,
	person_personID INT NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (person_personID) REFERENCES Person (personID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS MachineCategory
DROP TABLE IF EXISTS `MachineCategory`;
CREATE TABLE IF NOT EXISTS `MachineCategory` (
	machineCategoryId INT PRIMARY KEY AUTO_INCREMENT,
	machineCategoryName VARCHAR(25) NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS MuscleCategory
DROP TABLE IF EXISTS `MuscleCategory`;
CREATE TABLE IF NOT EXISTS `MuscleCategory` (
	muscleCategoryId INT PRIMARY KEY AUTO_INCREMENT,
	muscleCategoryName VARCHAR(25) NOT NULL,
	parentMuscleCategoryId INT,
	FOREIGN KEY (parentMuscleCategoryId) REFERENCES MuscleCategory (muscleCategoryId),
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Session
DROP TABLE IF EXISTS `Session`;
CREATE TABLE IF NOT EXISTS `Session` (
	sessionId INT PRIMARY KEY AUTO_INCREMENT,
	sessionName VARCHAR(100),
	sessionState SET('complete', 'unscheduled', 'canceled', 'scheduled', 'active') DEFAULT 'unscheduled',
	location_locationId INT,
	organization_organizationId INT,
	auctioneer_auctioneerId INT,
	timeslot_timeSlotId INT,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (location_locationId) REFERENCES `Location` (locationId),
	FOREIGN KEY (organization_organizationId) REFERENCES `Organization` (organizationId),
	FOREIGN KEY (auctioneer_auctioneerId) REFERENCES `Auctioneer` (auctioneerId),
	FOREIGN KEY (timeslot_timeSlotId) REFERENCES `TimeSlot` (timeSlotId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Lot
DROP TABLE IF EXISTS `Lot`;
CREATE TABLE IF NOT EXISTS `Lot` (
	lotId INT PRIMARY KEY AUTO_INCREMENT,
	lotName VARCHAR(100),
	lotPrice DECIMAL(10, 2) DEFAULT 0 CHECK (lotPrice >= 0),
	lotState SET('sold', 'on_sale', 'not_sold') DEFAULT 'not_sold',
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CREATE TABLE IF NOT EXISTS Session_Lot
DROP TABLE IF EXISTS `SessionLot`;
CREATE TABLE IF NOT EXISTS `SessionLot` (
	session_sessionId INT NOT NULL,
	lot_lotId INT NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (session_sessionId, lot_lotId),
	FOREIGN KEY (session_sessionId) REFERENCES `Session` (sessionId),
	FOREIGN KEY (lot_lotId) REFERENCES `Lot` (lotId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Item
DROP TABLE IF EXISTS `Item`;
CREATE TABLE IF NOT EXISTS `Item` (
	itemId INT PRIMARY KEY AUTO_INCREMENT,
	itemName VARCHAR(30),
	itemPrice DECIMAL(10, 2),
	itemCondition SET('used', 'new', 'partially used'),
	itemState SET('sold', 'on_sale', 'new'),
	machineCategory_machineCategoryId INT NULL,
	muscleCategory_muscleCategoryId INT,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (machineCategory_machineCategoryId) REFERENCES MachineCategory (machineCategoryId),
	FOREIGN KEY (muscleCategory_muscleCategoryId) REFERENCES MuscleCategory (muscleCategoryId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- CREATE TABLE IF NOT EXISTS ItemLot
DROP TABLE IF EXISTS `ItemLot`;
CREATE TABLE IF NOT EXISTS `ItemLot` (
	item_itemID INT NOT NULL, 
	lot_lotID INT NOT NULL, 
	PRIMARY KEY (item_itemID, lot_lotID), 
	FOREIGN KEY (item_itemID) REFERENCES Item (itemID), 
	FOREIGN KEY (lot_lotID) REFERENCES Lot (lotID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS ItemHistory
DROP TABLE IF EXISTS `ItemHistory`;
CREATE TABLE IF NOT EXISTS `ItemHistory` (
	itemHistoryId INT PRIMARY KEY AUTO_INCREMENT,
	item_itemID INT NOT NULL,
	itemName VARCHAR(30),
	itemPrice DECIMAL(10, 2),
	itemCondition SET('used', 'new', 'partially used'),
	itemState SET('sold', 'on_sale', 'new'),
	itemNote TEXT,
	itemParticipatedInBid BOOLEAN,
	itemSoldInBid BOOLEAN,
	machineCategory_machineCategoryId INT,
	muscleCategory_muscleCategoryId INT,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (item_itemID) REFERENCES Item (itemID),
	FOREIGN KEY (machineCategory_machineCategoryId) REFERENCES MachineCategory (machineCategoryId),
	FOREIGN KEY (muscleCategory_muscleCategoryId) REFERENCES MuscleCategory (muscleCategoryId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Bid
DROP TABLE IF EXISTS `Bid`;
CREATE TABLE IF NOT EXISTS `Bid` (
	bidId INT PRIMARY KEY AUTO_INCREMENT,
	bidAmount DECIMAL(10, 2) NOT NULL,
	participant_participantID INT NOT NULL,
	session_sessionId INT NOT NULL,
	lot_lotId INT NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (participant_participantID) REFERENCES Participant (participantID),
	FOREIGN KEY (session_sessionId, lot_lotId) REFERENCES SessionLot (session_sessionId, lot_lotID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- CREATE TABLE IF NOT EXISTS Transaction
DROP TABLE IF EXISTS `Transaction`;
CREATE TABLE IF NOT EXISTS `Transaction` (
	transactionId INT PRIMARY KEY AUTO_INCREMENT,
	session_sessionId INT NOT NULL,
	lot_lotId INT NOT NULL,
	transactionAmount DECIMAL(10, 2) NOT NULL,
	participant_participantID INT,
	bid_bidId INT,
	transactionState SET('success', 'failed', 'pending') DEFAULT 'pending',
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (bid_bidId) REFERENCES Bid (bidId),
	FOREIGN KEY (participant_participantID) REFERENCES Participant (participantID),
	FOREIGN KEY (session_sessionId, lot_lotId) REFERENCES SessionLot (session_sessionId, lot_lotId)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- CREATE TABLE IF NOT EXISTS tbl_logs
DROP TABLE IF EXISTS `tbl_logs`;
CREATE TABLE IF NOT EXISTS `tbl_logs` (
	logId INT PRIMARY KEY AUTO_INCREMENT,
	session_sessionId INT,
	session_sessionName VARCHAR(30),
	sessionState_old VARCHAR(15),
	sessionState_new VARCHAR(15),
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- CREATE TABLE IF NOT EXISTS tbl_delete_logs
DROP TABLE IF EXISTS `tbl_delete_logs`;
CREATE TABLE IF NOT EXISTS `tbl_delete_logs` (
	logId INT PRIMARY KEY AUTO_INCREMENT,
	session_sessionId INT,
	session_sessionName VARCHAR(30),
	logMessage VARCHAR(30) NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- CREATE TABLE IF NOT EXISTS tbl_generic_logs
DROP TABLE IF EXISTS `tbl_generic_logs`;
CREATE TABLE IF NOT EXISTS `tbl_generic_logs` (
	logId INT PRIMARY KEY AUTO_INCREMENT,
	resourceType VARCHAR(30) NOT NULL,
	logMessage TEXT NOT NULL,
	relatedId INT,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
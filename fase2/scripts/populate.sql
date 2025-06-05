-- Use the DB
USE ipm_bidding_system;

-- Disable FK checks
SET FOREIGN_KEY_CHECKS=0;

-- Delete data in the right order (child tables first)
TRUNCATE TABLE Bid;
TRUNCATE TABLE ItemHistory;
TRUNCATE TABLE ItemLot;
TRUNCATE TABLE SessionLot;
TRUNCATE TABLE ParticipantSession;
TRUNCATE TABLE Participant;
TRUNCATE TABLE Auctioneer;
TRUNCATE TABLE Session;
TRUNCATE TABLE Lot;
TRUNCATE TABLE Item;
TRUNCATE TABLE Person;
TRUNCATE TABLE Organization;
TRUNCATE TABLE Location;
TRUNCATE TABLE TimeSlot;
TRUNCATE TABLE MachineCategory;
TRUNCATE TABLE MuscleCategory;

-- Enable FK checks again
SET FOREIGN_KEY_CHECKS=1;


/* Populate: Insert default data for testing or initializing system */

INSERT INTO `TimeSlot` (timeSlotStartTime, timeSlotEndTime) VALUES 
('2025-01-01 08:00', '2025-01-01 10:00'),
('2025-01-01 10:00', '2025-01-01 12:00'),
('2025-01-01 12:00', '2025-01-01 14:00'),
('2025-01-01 14:00', '2025-01-01 16:00'),
('2025-01-01 16:00', '2025-01-01 18:00'),
('2025-01-01 18:00', '2025-01-01 20:00'),
('2025-01-01 20:00', '2025-01-01 22:00'),
('2025-01-01 22:00', '2025-01-01 00:00');


INSERT INTO `Location` (locationCountry, locationCity, locationAddress, locationPostalCode) VALUES
('Country1', 'City1', 'Address1', '2955-201'),
('Country2', 'City2', 'Address2', '2955-201'),
('Country3', 'City3', 'Address3', '2955-201'),
('Country4', 'City4', 'Address4', '2955-201'),
('Country5', 'City5', 'Address5', '2955-201'),
('Country6', 'City6', 'Address6', '2955-201'),
('Country7', 'City7', 'Address7', '2955-201'),
('Country8', 'City8', 'Address8', '2955-201'),
('Country9', 'City9', 'Address9', '2955-201'),
('Country10', 'City10', 'Address10', '2955-201'),
('Country11', 'City11', 'Address11', '2955-201'),
('Country12', 'City12', 'Address12', '2955-201'),
('Country13', 'City13', 'Address13', '2955-201'),
('Country14', 'City14', 'Address14', '2955-201'),
('Country15', 'City15', 'Address15', '2955-201'),
('Country16', 'City16', 'Address16', '2955-201'),
('Country17', 'City17', 'Address17', '2955-201'),
('Country18', 'City18', 'Address18', '2955-201'),
('Country19', 'City19', 'Address19', '2955-201'),
('Country20', 'City20', 'Address20', '2955-201');

INSERT INTO `Organization` (orgName) VALUES 
('Organization1'),
('Organization2'),
('Organization3'),
('Organization4'),
('Organization5'),
('Organization6'),
('Organization7'),
('Organization8'),
('Organization9'),
('Organization10'),
('Organization11'),
('Organization12'),
('Organization13'),
('Organization14'),
('Organization15'),
('Organization16'),
('Organization17'),
('Organization18'),
('Organization19'),
('Organization20');

INSERT INTO `Person` (personName, personEmail, personBirthDate, personNIF) VALUES
('Participant1', 'participant1@participant.com', '1990-01-01', 123456789),
('Participant2', 'participant2@participant.com', '1991-02-02', 234567890),
('Participant3', 'participant3@participant.com', '1992-03-03', 345678901),
('Participant4', 'participant4@participant.com', '1993-04-04', 456789012),
('Participant5', 'participant5@participant.com', '1994-05-05', 567890123),
('Participant6', 'participant6@participant.com', '1995-06-06', 678901234),
('Participant7', 'participant7@participant.com', '1996-07-07', 789012345),
('Participant8', 'participant8@participant.com', '1997-08-08', 890123456),
('Participant9', 'participant9@participant.com', '1998-09-09', 901234567),
('Participant10', 'participant10@participant.com', '1999-10-10', 012345678),
('Participant11', 'participant11@participant.com', '2000-11-11', 123456789),
('Participant12', 'participant12@participant.com', '2001-12-12', 234567890),
('Participant13', 'participant13@participant.com', '2002-01-01', 345678901),
('Participant14', 'participant14@participant.com', '2003-02-02', 456789012),
('Participant15', 'participant15@participant.com', '2004-03-03', 567890123),
('Participant16', 'participant16@participant.com', '2005-04-04', 678901234),
('Auctioneer1', 'aurtioneer1@auctioneer.com', '2009-08-08', 012345678),
('Auctioneer2', 'aurtioneer2@auctioneer.com', '2003-02-22', 012346898),
('Auctioneer3', 'aurtioneer3@auctioneer.com', '2003-04-03', 012345654);


-- #TODO Maybe make ii so we dont manually provide IDs?
INSERT INTO `Participant` (person_personID) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16);

-- #TODO Maybe make ii so we dont manually provide IDs?
INSERT INTO `Auctioneer` (person_personID) VALUES
(17),
(18),
(19);


INSERT INTO `MachineCategory` (machineCategoryName) VALUES 
('freeweight'),
('plated'),
('hydraulic'),
('cardio'), 
('other');

INSERT INTO `MuscleCategory` (muscleCategoryName, parentMuscleCategoryId) VALUES 
('arms', NULL),
('legs', NULL),
('chest', NULL),
('back', NULL),
('shoulder', NULL),
('tricep', 1),
('bicep', 1),
('quads', 2);

INSERT INTO `Lot` (lotName, lotPrice, lotState) VALUES
('Lot1', NULL, 'new'),
('Lot2', NULL, 'new'),
('Lot3', NULL, 'new'),
('Lot4', NULL, 'new'),
('Lot5', NULL, 'new'),
('Lot6', NULL, 'new'),
('Lot7', NULL, 'new'),
('Lot8', NULL, 'new'),
('Lot9', NULL, 'new'),
('Lot10', NULL, 'new'),
('Lot11', NULL, 'new'),
('Lot12', NULL, 'new'),
('Lot13', NULL, 'new'),
('Lot14', NULL, 'new'),
('Lot15', NULL, 'new'),
('Lot16', NULL, 'new'),
('Lot17', NULL, 'new'),
('Lot18', NULL, 'new'),
('Lot19', NULL, 'new'),
('Lot20', NULL, 'new');

INSERT INTO `Item` (itemName, itemPrice, itemCondition, itemState, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES 
('Item1', 10.00, 'new', 'new', 1, 1),
('Item2', 20.00, 'new', 'new', 2, 2),
('Item3', 30.00, 'new', 'new', 3, 3),
('Item4', 40.00, 'new', 'new', 4, 4),
('Item5', 50.00, 'new', 'new', 5, 5),
('Item6', 60.00, 'new', 'new', 1, 6),
('Item7', 70.00, 'new', 'new', 2, 7),
('Item8', 80.00, 'new', 'new', 3, 3),
('Item9', 90.00, 'new', 'new', 4, 4),
('Item10', 100.00, 'new', 'new', 5, 5),
('Item11', 110.00, 'new', 'new', 1, 6),
('Item12', 120.00, 'new', 'new', 2, 7),
('Item13', 130.00, 'new', 'new', 3, 3),
('Item14', 140.00, 'new', 'new', 4, 4),
('Item15', 150.00, 'new', 'new', 5, 5),
('Item16', 160.00, 'new', 'new', 1, 1),
('Item17', 170.00, 'new', 'new', 2, 2),
('Item18', 180.00, 'new', 'new', 3, 3),
('Item19', 190.00, 'new', 'new', 4, 4),
('Item20', 200.00, 'new', 'new', 5, 5);

INSERT INTO `ItemHistory` (item_itemID, itemName, itemPrice, itemCondition, itemState, itemNote, 
itemParticipatedInBid, itemSoldInBid, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES 
(1, 'Item1', 10.00, 'new', 'new', NULL, NULL, NULL, 1, 1),
(2, 'Item2', 20.00, 'new', 'new', NULL, NULL, NULL, 2, 2),
(3, 'Item3', 30.00, 'new', 'new', NULL, NULL, NULL, 3, 3),
(4, 'Item4', 40.00, 'new', 'new', NULL, NULL, NULL, 4, 4),
(5, 'Item5', 50.00, 'new', 'new', NULL, NULL, NULL, 5, 5),
(6, 'Item6', 60.00, 'new', 'new', NULL, NULL, NULL, 1, 6),
(7, 'Item7', 70.00, 'new', 'new', NULL, NULL, NULL, 2, 7),
(8, 'Item8', 80.00, 'new', 'new', NULL, NULL, NULL, 3, 3),
(9, 'Item9', 90.00, 'new', 'new', NULL, NULL, NULL, 4, 4),
(10, 'Item10', 100.00, 'new', 'new', NULL, NULL, NULL, 5, 5),
(11, 'Item11', 110.00, 'new', 'new', NULL, NULL, NULL, 1, 6),
(12, 'Item12', 120.00, 'new', 'new', NULL, NULL, NULL, 2, 7),
(13, 'Item13', 130.00, 'new', 'new', NULL, NULL, NULL, 3, 3),
(14, 'Item14', 140.00, 'new', 'new', NULL, NULL, NULL, 4, 4),
(15, 'Item15', 150.00, 'new', 'new', NULL, NULL, NULL, 5, 5),
(16, 'Item16', 160.00, 'new', 'new', NULL, NULL, NULL, 1, 1),
(17, 'Item17', 170.00, 'new', 'new', NULL, NULL, NULL, 2, 2),
(18, 'Item18', 180.00, 'new', 'new', NULL, NULL, NULL, 3, 3),
(19, 'Item19', 190.00, 'new', 'new', NULL, NULL, NULL, 4, 4),
(20, 'Item20', 200.00, 'new', 'new', NULL, NULL, NULL, 5, 5);


-- // USE Procedure to add a SESSION
-- // USE Procedure to add a PARTICIPANT to a SESSION
-- // USE Procedure to add  lot to session
-- // USE Procedure to add item to lot
-- // USE Procedure to add bid
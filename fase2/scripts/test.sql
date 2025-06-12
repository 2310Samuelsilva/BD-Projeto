
--###########################################
-- Testes iniciais 
--###########################################

-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE `Session`;
-- -- Enable foreign key checks
-- SET FOREIGN_KEY_CHECKS = 1;

--###########################################

-- Testar views

SELECT * FROM vw_active_sessions;
SELECT * FROM vw_active_lots;
SELECT * FROM vw_highest_bids_per_lot;
SELECT * FROM vw_item_lot_details;
SELECT * FROM vw_orphan_lots;
SELECT * FROM vw_participant_details;

-- Testar stored procedures

-- Criar um leilao
CALL sp_criar_leilao('Test_Session', 1, 1, 1, 1);
SELECT * FROM `Session` WHERE sessionName = 'Test_Session';
SELECT sessionId INTO @sessionId FROM `Session` WHERE sessionName = 'Test_Session';


-- Adicionar participantes
CALL sp_adicionar_participante(1, @sessionId);
SELECT * FROM ParticipantSession WHERE participant_participantID = 1 AND session_sessionId = @sessionId;

-- Remover auctonieer
SELECT * FROM Auctioneer WHERE auctioneerId = 1;
CALL sp_delete_auctioneer(1);
SELECT * FROM Auctioneer WHERE auctioneerId = 1;
SELECT * FROM `Session` WHERE sessionId = @sessionId;

-- Remover Item
INSERT INTO `Item` (itemName, itemPrice, itemCondition, itemState, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES
('TestItem', 100.00, 'used', 'new', 1, 1);
SELECT itemID INTO @itemId1 FROM Item WHERE itemName = 'TestItem';
SELECT * FROM Item WHERE itemID = @itemId1;
CALL sp_delete_item(@itemId1);
SELECT * FROM Item WHERE itemID = @itemId1;
SELECT * FROM ItemLot WHERE item_itemID = @itemId1;

-- Remover ItemHistory
INSERT INTO `ItemHistory` (item_itemID, itemName, itemPrice, itemCondition, itemState, itemNote, 
itemParticipatedInBid, itemSoldInBid, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES 
(1, 'TestItem', 100.00, 'used', 'new', 'TestNote', 1, 1, 1, 1);

SELECT itemHistoryId INTO @itemHistoryId1 FROM ItemHistory WHERE itemName = 'TestItem';
SELECT * FROM ItemHistory WHERE itemHistoryId = @itemHistoryId1;
CALL sp_delete_itemHistory(@itemHistoryId1);
SELECT * FROM ItemHistory WHERE itemHistoryId = @itemHistoryId1;


-- Remover Location
SELECT * FROM `Session` WHERE location_locationId = 1;
CALL sp_delete_location(1);
SELECT * FROM `Location` WHERE locationId = 1;
SELECT * FROM `Session` WHERE location_locationId = 1;


-- Remover Lot
INSERT INTO `Lot` (lotName, lotPrice) VALUES ('TestLot', NULL);
SELECT lotId INTO @lotId1 FROM Lot WHERE lotName = 'TestLot';
SELECT * FROM Lot WHERE lotId = @lotId1;
CALL sp_delete_lot(@lotId1);
SELECT * FROM Lot WHERE lotId = @lotId1;
SELECT * FROM ItemLot WHERE lot_lotID = @lotId1;
SELECT * FROM SessionLot WHERE lot_lotID = @lotId1;
SELECT * FROM Bid WHERE lot_lotID = @lotId1;

-- Remover machine category
SELECT * FROM MachineCategory;
SELECT * FROM `Item` WHERE machineCategory_machineCategoryId = 1;
CALL sp_delete_machineCategory(1);
SELECT * FROM `MachineCategory` WHERE machineCategoryId = 1;
SELECT * FROM `Item`;


-- Remover muscle category
SELECT * FROM MuscleCategory;
SELECT * FROM `Item` WHERE muscleCategory_muscleCategoryId = 1;
CALL sp_delete_muscleCategory(1);
SELECT * FROM `MuscleCategory` WHERE muscleCategoryId = 1;
SELECT * FROM `Item`;

-- Remover Organization
SELECT * FROM `Organization`;
SELECT * FROM `Session` WHERE organization_organizationId = 1;
CALL sp_delete_organization(1);
SELECT * FROM `Organization` WHERE organizationId = 1;
SELECT * FROM `Session`;

-- Remover Participant
SELECT * FROM `Participant`;
SELECT * FROM `ParticipantSession` WHERE participant_participantId = 1;
CALL sp_delete_participant(5);
SELECT * FROM `ParticipantSession` WHERE participant_participantID = 1;

-- Remover person
SELECT * FROM `Person`;
SELECT * FROM `Participant` WHERE person_personId = 1;
CALL sp_delete_person(2);
SELECT * FROM `Person` WHERE personId = 1;
SELECT * FROM `Participant`;

-- Remover TimeSlot
SELECT * FROM `TimeSlot`;
SELECT * FROM `Session` WHERE timeSlot_timeSlotId = 1;
CALL sp_delete_timeSlot(1);
SELECT * FROM `TimeSlot` WHERE timeSlotId = 1;
SELECT * FROM `Session`;

-- Remover transaction
SELECT * FROM `Transaction`;
CALL sp_delete_transaction(1);
SELECT * FROM `Transaction` WHERE transactionId = 1;




-- Adicionar lot a sessao
CALL sp_add_lot_to_session(7, 1);
SELECT * FROM SessionLot WHERE lot_lotId = 1 AND session_sessionId = 1;

-- Clonar leilao
CALL sp_clonar_leilao(1, @newSessionId);
SELECT * FROM Session WHERE sessionId = @newSessionId;

-- Remover leilao , force 
CALL sp_remover_leilao(@newSessionId, 1);
SELECT * FROM `Session` WHERE sessionId = @newSessionId;
SELECT * FROM ParticipantSession WHERE session_sessionId = @newSessionId;
SELECT * FROM SessionLot WHERE session_sessionId = @newSessionId;

-- Remover leilao , com erro porque tem dados dependentes
CALL sp_remover_leilao(@sessionId, 0);
SELECT * FROM `Session` WHERE sessionId = @sessionId;

-- Remover leilao
CALL sp_criar_leilao('Session_delete', 4, 2, 2, 2);
SELECT sessionID INTO @deleteSessionId FROM Session WHERE sessionName = 'Session_delete';
CALL sp_remover_leilao(@deleteSessionId, 0);
SELECT * FROM `Session` WHERE sessionId = @deleteSessionId;
SELECT * FROM ParticipantSession WHERE session_sessionId = @deleteSessionId;
SELECT * FROM SessionLot WHERE session_sessionId = @deleteSessionId;


-- Fechar sessao
CALL sp_close_session(1);
SELECT * FROM Session WHERE sessionID = 1;









-- ########################################
-- FINAL GENERAL TEST SCRIPT: DEMONSTRATION
-- ########################################

-- Step 1: Create Items
INSERT INTO `Item` (itemName, itemPrice, itemCondition, itemState, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES
('FinalTest_Item1', 150.00, 'used', 'new', 3, 2),
('FinalTest_Item2', 300.00, 'new', 'new', 3, 3);

SELECT itemID INTO @ft_itemId1 FROM Item WHERE itemName = 'FinalTest_Item1';
SELECT itemID INTO @ft_itemId2 FROM Item WHERE itemName = 'FinalTest_Item2';

-- Step 2: Create Lot and Add Items
INSERT INTO `Lot` (lotName, lotPrice) VALUES ('FinalTest_Lot', NULL);
SELECT lotId INTO @ft_lotId FROM Lot WHERE lotName = 'FinalTest_Lot';

CALL sp_add_item_to_lot(@ft_itemId1, @ft_lotId);
CALL sp_add_item_to_lot(@ft_itemId2, @ft_lotId);

SELECT * FROM ItemLot WHERE lot_lotID = @ft_lotId;

-- Check price update from triggers
SELECT lotPrice AS "Lot Price after Insert" FROM Lot WHERE lotId = @ft_lotId;

-- Step 3: Create Auction Session
CALL sp_criar_leilao('FinalTest_Session', 1, 1, 1, 1);
SELECT sessionID INTO @ft_sessionId FROM Session WHERE sessionName = 'FinalTest_Session';

-- Add Lot to Session
CALL sp_add_lot_to_session(@ft_lotId, @ft_sessionId);

-- Add Participants
CALL sp_adicionar_participante(1, @ft_sessionId);
CALL sp_adicionar_participante(2, @ft_sessionId);

-- Step 4: Start Auction & Place Bids
CALL sp_start_session(@ft_sessionId);
SELECT * FROM `Session` WHERE sessionId = @ft_sessionId;
SELECT * FROM `SessionLot` WHERE session_sessionId = @ft_sessionId;

CALL sp_add_bid(100.00, 1, @ft_sessionId, @ft_lotId);
CALL sp_add_bid(250.00, 2, @ft_sessionId, @ft_lotId);

SELECT * FROM Bid WHERE lot_lotID = @ft_lotId AND session_sessionId = @ft_sessionId;

-- Step 5: Clone Auction
CALL sp_clonar_leilao(@ft_sessionId, @ft_clonedSessionId);
SELECT * FROM Session WHERE sessionId = @ft_clonedSessionId;

-- Step 6: Close & Cleanup
CALL sp_close_session(@ft_sessionId);
CALL sp_remover_leilao(@ft_sessionId, 0);
CALL sp_remover_leilao(@ft_clonedSessionId, 1);

-- Step 7: Trigger Audit Logs Test
-- Update session name to trigger log
CALL sp_criar_leilao('Final_Trigger_Test', 3, 3, 3, 3);
SELECT sessionID INTO @logSessionId FROM Session WHERE sessionName = 'Final_Trigger_Test';

UPDATE Session SET sessionName = 'Final_Trigger_Test_Updated' WHERE sessionID = @logSessionId;
UPDATE Session SET sessionState = 'complete' WHERE sessionID = @logSessionId;

-- Check logs
SELECT * FROM tbl_logs;

-- Clean up
CALL sp_remover_leilao(@logSessionId, 0);

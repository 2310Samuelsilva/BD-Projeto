-- Todas as stored procedures, triggers e views estao definidas no ficheiro logic.sql


INSERT INTO `Item` (itemName, itemPrice, itemCondition, itemState, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES 
('Results_Haltere 5Kg', 30.00, 'used', 'new', 1, 1),
('Results_Peito', 100.00, 'new', 'new', 2, 3);

SELECT itemID INTO @itemId1 FROM Item WHERE itemName = 'Results_Haltere 5Kg';
SELECT itemID INTO @itemId2 FROM Item WHERE itemName = 'Results_Peito';

-- Create Lots
INSERT INTO `Lot` (lotName, lotPrice) VALUES ('Results_Lot', NULL);
INSERT INTO `Lot` (lotName, lotPrice) VALUES ('Results_Lot2', NULL);

SELECT lotId INTO @lotId1 FROM Lot WHERE lotName = 'Results_Lot';
SELECT lotId INTO @lotId2 FROM Lot WHERE lotName = 'Results_Lot2';

-- Add item to lot
CALL sp_add_item_to_lot(@itemId1, @lotId1);
CALL sp_add_item_to_lot(@itemId2, @lotId1);

CALL sp_criar_leilao('Results_Session', 1, 1, 1, 1);

-- Get the session ID
SELECT sessionID INTO @sessionId FROM Session WHERE sessionName = 'Results_Session';

-- Add the lot to the session
CALL sp_add_lot_to_session(@lotId1, @sessionId);

SET @participantId1 = 1;
SET @participantId2 = 2;
CALL sp_adicionar_participante(@participantId1, @sessionId);
CALL sp_adicionar_participante(@participantId2, @sessionId);


CALL sp_start_session(@sessionId);
SELECT @participantId1, @lotId1, @sessionId;

CALL sp_add_bid(5.0, @participantId1, @sessionId, @lotId1);
CALL sp_add_bid(10.0, @participantId2, @sessionId, @lotId1);
CALL sp_add_bid(20.0, @participantId1, @sessionId, @lotId1);
CALL sp_add_bid(25.0, @participantId2, @sessionId, @lotId1);
CALL sp_add_bid(30.0, @participantId1, @sessionId, @lotId1);
CALL sp_add_bid(60.0, @participantId2, @sessionId, @lotId1);

CALL sp_clonar_leilao(@sessionId, @clonedSessionId);
SELECT * FROM Session WHERE sessionId = @clonedSessionId;


SELECT @sessionId;
CALL sp_remover_leilao(@sessionId, 0);



-- Delete Session
CALL sp_criar_leilao('Session_delete', 1, 1, 1, 1);
SELECT sessionID INTO @deleteSessionId FROM Session WHERE sessionName = 'Session_delete';
CALL sp_remover_leilao(@deleteSessionId, 0);
CALL sp_remover_leilao(@clonedSessionId, 1);



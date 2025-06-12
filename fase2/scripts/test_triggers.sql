
INSERT INTO `Item` (itemName, itemPrice, itemCondition, itemState, machineCategory_machineCategoryId, muscleCategory_muscleCategoryId) VALUES 
('TestTrigger_Peso 5Kg', 100.00, 'used', 'new', 1, 1),
('TestTrigger_Peso 15Kg', 100.00, 'new', 'new', 2, 3);

SELECT itemID INTO @itemId1 FROM Item WHERE itemName = 'TestTrigger_Peso 5Kg';
SELECT itemID INTO @itemId2 FROM Item WHERE itemName = 'TestTrigger_Peso 15Kg';


-- Create Lots
INSERT INTO `Lot` (lotName, lotPrice) VALUES ('TestTrigger_Lot', NULL);
SELECT lotId INTO @lotId1 FROM Lot WHERE lotName = 'TestTrigger_Lot';



-- Add item to lot
CALL sp_add_item_to_lot(@itemId1, @lotId1);
SELECT lotPrice AS "Preco do Lote apos inserir item" FROM Lot WHERE lotId = @lotId1;

CALL sp_add_item_to_lot(@itemId2, @lotId1);
SELECT lotPrice AS "Preco do Lote apos inserir item2" FROM Lot WHERE lotId = @lotId1;


SELECT lotPrice AS "Preco do Lote" FROM Lot WHERE lotId = @lotId1;
UPDATE Item SET itemPrice = 50.00 WHERE itemID = @itemId1;
SELECT lotPrice AS "Preco do Lote Apos Update de Item" FROM Lot WHERE lotId = @lotId1;

DELETE FROM ItemLot WHERE item_itemID = @itemId2 AND lot_lotID = @lotId1;
SELECT lotPrice AS "Preco do Lote Apos Remover Item" FROM Lot WHERE lotId = @lotId1;



CALL sp_criar_leilao('TestTrigger_Session', 1, 1, 1, 1);

-- Get the session ID
SELECT sessionID INTO @sessionId FROM Session WHERE sessionName = 'TestTrigger_Session';
CALL sp_start_session(@sessionId);

SELECT * FROM tbl_logs;
UPDATE `Session` SET sessionState = 'complete' WHERE sessionId = @sessionId;
UPDATE `Session` SET sessionName = 'TestTrigger_SessionUpdate' WHERE sessionId = @sessionId;

SELECT * FROM tbl_logs;

CALL sp_remover_leilao(@sessionId, 0);

SELECT * FROM tbl_logs;
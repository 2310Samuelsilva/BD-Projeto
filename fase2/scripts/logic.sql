





/*######################
        ENUNCIADO
########################*/


/* SP1 : sp_criar_leilao

Cria um novo leilão/evento, enviando todos os dados necessários à definição do mesmo;
Criar uma nova SESSION.

#IDEIA: Validar se existe uma sessao com a mesma localizacao e mesmo timeslot, nesse caso retornar erro
*/

DROP PROCEDURE IF EXISTS sp_criar_leilao; 

DELIMITER $$
CREATE PROCEDURE sp_criar_leilao(IN sessionName VARCHAR(100), 
        IN location_locationId INT,
        IN organization_organizationId INT,
        IN auctioneer_auctioneerId INT,
        IN timeslot_timeSlotId INT)
BEGIN

    INSERT INTO Session (sessionName, location_locationId, organization_organizationId, auctioneer_auctioneerId, timeslot_timeSlotId)
    VALUES (sessionName, location_locationId, organization_organizationId, auctioneer_auctioneerId, timeslot_timeSlotId);
END$$
DELIMITER ; 


/* SP2 :  sp_adicionar_participante(id_leilao, …)

Adiciona uma pessoa à lista de participantes que irão fazer parte do leilão indicado;

#IDEA: Validar se participante já está numa sessao ao mesmo tempo, nesse caso ignorar 
*/

DROP PROCEDURE IF EXISTS sp_adicionar_participante; 
DELIMITER $$
CREATE PROCEDURE sp_adicionar_participante(
        IN participantId INT,
        IN sessionId INT)
BEGIN 

    INSERT INTO ParticipantSession (participant_participantID, session_sessionId)
    VALUES (participantId, sessionId);

END$$
DELIMITER ;


/* SP3 : sp_criar_transacao(id_leilao, id_participante, …) 

Regista o resultado do participante no leilão/evento indicado;
*/



/* SP4 : sp_remover_leilao(id_leilao, force, …) 

Remove o leilão/evento identificado no parâmetro, nas seguintes circunstâncias:

a. Caso não existam resultados associados à leilão/evento (ou outros registos que sejam
dependentes);
b. Caso existam resultados associados ao leilão/evento e tenha sido enviado "True" no
parâmetro force;
c. Caso contrário, devolve um erro.

*/

DROP PROCEDURE IF EXISTS sp_remover_leilao;
DELIMITER $$
CREATE PROCEDURE sp_remover_leilao(IN sessionId INT, IN forceDelete BOOLEAN)
BEGIN
        IF fn_can_delete_session(sessionId) OR forceDelete THEN
                CALL sp_delete_session(sessionId);
        ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leilao nao pode ser removido';
        END IF;
END$$
DELIMITER ;
        


/* SP5 :  sp_clonar_leilao(id_leilao, …) 

Cria um novo leilão/evento com uma cópia de todos os dados existentes no leilão/evento indicada como parâmetro. 
A única exceção é que, à descrição do leilão, deverá ser adicionada a string " --- COPIA (a preencher)".
*/

DROP PROCEDURE IF EXISTS sp_clonar_leilao;
DELIMITER $$
CREATE PROCEDURE sp_clonar_leilao(IN sessionId INT)
BEGIN

  DECLARE newSessionId INT;

  INSERT INTO `Session` (sessionName, location_locationId, organization_organizationId, auctioneer_auctioneerId, timeslot_timeSlotId)
  SELECT 
    CONCAT(sessionName, '  --- COPIA (a preencher)'),
    location_locationId,
    organization_organizationId,
    auctioneer_auctioneerId,
    timeslot_timeSlotId
  FROM `Session`
  WHERE sessionId = sessionId;

  SET newSessionId = LAST_INSERT_ID();

  /*
  Se for necessario incluir todos os dados relacionados

  INSERT INTO SessionLot (session_sessionId, lot_lotId)
  SELECT 
    newSessionId,
    lot_lotId
  FROM SessionLot
  WHERE session_sessionId = sessionId;

  Adicionar outros
  */
  
  -- Optionally return the new sessionId
  SELECT newSessionId AS "Nova Sessao";
END$$
DELIMITER ;

/*###########
    DELETE
#############*/


/* SP6 : sp_delete_session(sessionId)
  Delete a session and all related data, loop through all bids and delete them using the dedicated procedure
*/

DROP PROCEDURE IF EXISTS sp_delete_session;
DELIMITER $$

CREATE PROCEDURE sp_delete_session(IN p_sessionId INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_bidId INT;
    DECLARE bid_cursor CURSOR FOR
        SELECT `bidId` FROM `Bid` WHERE `session_sessionId` = `p_sessionId`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    

    -- Loop through all bids and delete them using the dedicated procedure
    OPEN bid_cursor;
    bid_loop: LOOP
        FETCH bid_cursor INTO v_bidId;
        
        IF done THEN
            LEAVE bid_loop;
        END IF;
        CALL sp_delete_bid(v_bidId);
    END LOOP;
    CLOSE bid_cursor;

    DELETE FROM `ParticipantSession` WHERE session_sessionId = p_sessionId;
    DELETE FROM `SessionLot` WHERE session_sessionId = p_sessionId;
    DELETE FROM `Session` WHERE sessionId = p_sessionId;
END$$

DELIMITER ;



/* SP7 : sp_delete_auctioneer(auctioneerId)
 Delete an auctioneer and all related data, set session.auctioneer_auctioneerId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_auctioneer;
DELIMITER $$
CREATE PROCEDURE sp_delete_auctioneer(IN p_auctioneerId INT)
BEGIN
    UPDATE `Session` SET auctioneer_auctioneerId = NULL WHERE auctioneer_auctioneerId = p_auctioneerId;
    DELETE FROM `Auctioneer` WHERE auctioneerId = p_auctioneerId;
END$$
DELIMITER ;

/* SP8 : sp_delete_bid(p_bidId)
  Delete a bid and all related data, set transaction.bid_bidId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_bid;
DELIMITER $$
CREATE PROCEDURE sp_delete_bid(IN p_bidId INT)
BEGIN
    UPDATE `Transaction` SET bid_bidId = NULL WHERE bid_bidId = p_bidId;
    DELETE FROM `Bid` WHERE bidId = p_bidId;
END$$
DELIMITER ;


/* SP9 : sp_delete_item(p_itemId)
  Delete an item and all related data
*/
DROP PROCEDURE IF EXISTS sp_delete_item;
DELIMITER $$
CREATE PROCEDURE sp_delete_item(IN p_itemId INT)
BEGIN

    DECLARE v_itemHistoryId INT;
    SELECT itemHistoryId INTO v_itemHistoryId FROM `ItemHistory` WHERE item_itemID = p_itemId;

    CALL sp_delete_itemHistory(v_itemHistoryId);
    
    DELETE FROM `ItemLot` WHERE item_itemID = p_itemId;
    DELETE FROM `Item` WHERE itemID = p_itemId;
END$$
DELIMITER ;

/* SP10 : sp_delete_itemHistory(p_itemHistoryId)
  Delete an itemHistory and all related data
*/
DROP PROCEDURE IF EXISTS sp_delete_itemHistory;
DELIMITER $$
CREATE PROCEDURE sp_delete_itemHistory(IN p_itemHistoryId INT)
BEGIN
    DELETE FROM `ItemHistory` WHERE itemHistoryId = p_itemHistoryId;
END$$
DELIMITER ;

/* SP11 : sp_delete_location(p_locationId)
  Delete a location and all related data, set session.location_locationId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_location;
DELIMITER $$
CREATE PROCEDURE sp_delete_location(IN  p_locationId INT)
BEGIN
    UPDATE `Session` SET location_locationId = NULL WHERE location_locationId = p_locationId;
    DELETE FROM `Location` WHERE locationId = p_locationId;
END$$
DELIMITER ;

/* SP12 : sp_delete_lot(lotId)
  Delete a lot and all related data, loop through all bids and delete them using the dedicated procedure
*/
DROP PROCEDURE IF EXISTS sp_delete_lot;
DELIMITER $$

CREATE PROCEDURE sp_delete_lot(IN p_lotId INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_bidId INT;
    DECLARE bid_cursor CURSOR FOR
        SELECT bidId FROM `Bid` WHERE lot_lotId = p_lotId;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Delete each bid associated with this lot using the dedicated SP
    OPEN bid_cursor;
    bid_loop: LOOP
        FETCH bid_cursor INTO v_bidId;
        IF done THEN
            LEAVE bid_loop;
        END IF;
        CALL sp_delete_bid(v_bidId);
    END LOOP;
    CLOSE bid_cursor;

    
    DELETE FROM `ItemLot` WHERE lot_lotId = p_lotId;
    DELETE FROM `SessionLot` WHERE lot_lotId = p_lotId;

    -- Finally, remove the lot itself
    DELETE FROM Lot WHERE lotId = p_lotId;
END$$

DELIMITER ;

/* SP13 : sp_delete_machineCategory(p_machineCategoryId)
  Delete an itemHistory and all related data, set item.machineCategory_machineCategoryId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_machineCategory;
DELIMITER $$
CREATE PROCEDURE sp_delete_machineCategory(IN p_machineCategoryId INT)
BEGIN
    UPDATE `Item` SET machineCategory_machineCategoryId = NULL WHERE machineCategory_machineCategoryId = p_machineCategoryId;
    UPDATE `ItemHistory` SET machineCategory_machineCategoryId = NULL WHERE machineCategory_machineCategoryId = p_machineCategoryId;
    DELETE FROM `MachineCategory` WHERE machineCategoryId = p_machineCategoryId;
END$$
DELIMITER ;


/* SP14 : sp_delete_muscleCategory(p_muscleCategoryId)
  Delete an itemHistory and all related data, set item.muscleCategory_muscleCategoryId to NULL, 
  set itemHistory.muscleCategory_muscleCategoryId to NULL, 
  set muscleCategory.parentMuscleCategoryId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_muscleCategory;
DELIMITER $$
CREATE PROCEDURE sp_delete_muscleCategory(IN p_muscleCategoryId INT)
BEGIN
    UPDATE `Item` SET muscleCategory_muscleCategoryId = NULL WHERE muscleCategory_muscleCategoryId = p_muscleCategoryId;
    UPDATE `ItemHistory` SET muscleCategory_muscleCategoryId = NULL WHERE muscleCategory_muscleCategoryId = p_muscleCategoryId;
    UPDATE `MuscleCategory` SET parentMuscleCategoryId = NULL WHERE parentMuscleCategoryId = p_muscleCategoryId;
    DELETE FROM `MuscleCategory` WHERE muscleCategoryId = p_muscleCategoryId;
END$$
DELIMITER ;


/* SP15 : sp_delete_organization(p_organizationId)
  Delete an organization and all related data, set session.organization_organizationId to NULL
*/
DROP PROCEDURE IF EXISTS sp_delete_organization;
DELIMITER $$
CREATE PROCEDURE sp_delete_organization(IN p_organizationId INT)
BEGIN
    UPDATE `Session` SET organization_organizationId = NULL WHERE organization_organizationId = p_organizationId;
    DELETE FROM `Organization` WHERE organizationId = p_organizationId;

END$$
DELIMITER ;

/* SP16 : sp_delete_participant(p_participantId)
  Delete a participant and all related data, loop through all bids and delete them using the dedicated procedure
*/
DROP PROCEDURE IF EXISTS sp_delete_participant;
DELIMITER $$

CREATE PROCEDURE sp_delete_participant(IN p_participantId INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_bidId INT;
    DECLARE bid_cursor CURSOR FOR
        SELECT bidId FROM `Bid` WHERE participant_participantId = p_participantId;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    
    -- Delete each bid associated with this participant using the dedicated SP
    OPEN bid_cursor;
    bid_loop: LOOP
        FETCH bid_cursor INTO v_bidId;
        IF done THEN
            LEAVE bid_loop;
        END IF;
        CALL sp_delete_bid(v_bidId);
    END LOOP;
    CLOSE bid_cursor;

    -- Remove links to sessions
    DELETE FROM `ParticipantSession` WHERE participant_participantId = p_participantId;

    -- Finally, delete the participant
    DELETE FROM `Participant` WHERE participantId = p_participantId;
END$$

DELIMITER ;


/* SP17 : sp_delete_person(p_personId)
  Delete a person and all related data
*/
DROP PROCEDURE IF EXISTS sp_delete_person;
DELIMITER $$
CREATE PROCEDURE sp_delete_person(IN p_personId INT)
BEGIN
    DECLARE v_participantId INT;
    DECLARE v_auctioneerId INT;

    -- Declarations must come before any executable statements
    SELECT participantId INTO v_participantId FROM `Participant` WHERE person_personId = p_personId;
    SELECT auctioneerId INTO v_auctioneerId FROM `Auctioneer` WHERE person_personId = p_personId;

    IF v_participantId IS NOT NULL THEN
        CALL sp_delete_participant(v_participantId);
    END IF;

    IF v_auctioneerId IS NOT NULL THEN
        CALL sp_delete_auctioneer(v_auctioneerId);
    END IF;

    DELETE FROM `Person` WHERE personId = p_personId;
END$$
DELIMITER ;

/* SP18 : sp_delete_timeSlot(timeSlotId)
  Delete a timeSlot and all related data
*/
DROP PROCEDURE IF EXISTS sp_delete_timeSlot;
DELIMITER $$
CREATE PROCEDURE sp_delete_timeSlot(IN p_timeSlotId INT)
BEGIN
    UPDATE `Session` SET timeSlot_timeSlotId = NULL WHERE timeSlot_timeSlotId = p_timeSlotId;
    DELETE FROM `TimeSlot` WHERE timeSlotId = p_timeSlotId;
END$$
DELIMITER ;


/* SP19 : sp_delete_transaction(p_transactionId)
  Delete a transaction and all related data
*/
DROP PROCEDURE IF EXISTS sp_delete_transaction;
DELIMITER $$
CREATE PROCEDURE sp_delete_transaction(IN p_transactionId INT)
BEGIN
    DELETE FROM `Transaction` WHERE transactionId = p_transactionId;
END$$
DELIMITER ;



/* #########
  Triggers
  ######### */

/* Diferente do enunciado pois uma session nao tem um valor mas sim o seu estado.
   Trigger utilizado para registar mudanca de estado de uma sessão
*/

DROP TRIGGER IF EXISTS result_change;
DELIMITER $$
CREATE TRIGGER result_change AFTER UPDATE ON `Session` FOR EACH ROW
BEGIN
    INSERT INTO `tbl_logs` (session_sessionId, session_sessionName, sessionState_old, sessionState_new)
    VALUES (NEW.sessionId, NEW.sessionName, OLD.sessionState, NEW.sessionState);
END$$
DELIMITER ; 


/* 
   Trigger utilizado para registar o apagar de uma sessao
*/

DROP TRIGGER IF EXISTS result_delete;
DELIMITER $$
CREATE TRIGGER result_delete AFTER DELETE ON `Session` FOR EACH ROW
BEGIN
    INSERT INTO `tbl_logs_delete` (session_sessionId, session_sessionName, logMessage)
    VALUES (OLD.sessionId, OLD.sessionName, 'Session deleted');
END$$
DELIMITER ; 




/*######################
        CUSTOM 
########################
(Enunciado ponto 2 - 1.2)
*/



-- custom logic 
-- 5 views
-- 2 stored functions
-- 5 stored procedure
-- 2 triggers

-- View 1 : Sessoes ativas
-- View 2 : Session Lots
-- View 3 : Detalhes de um Item
-- View 4 : Taxa de sucesso (lotes vendidos vs. não vendidos) por sessão
-- View 5 : Leiloeiros com mais sessões realizadas ou maior volume de vendas

-- Function 1 : fn_isItemOnActiveSession
-- Function 2 : 

-- Procedure 1 : Get Lots for Item 
-- Procedure 2 : Get Sessions with item of category
-- Procedure 3 : Assign Lot to Session
-- Procedure 4 : Count how many times an item has been on a session, helpful to understand low selling items
-- Procedure 5 : Mark Lot as sold
-- Procedure 6 : Add auctonieer to session
-- Procedure 7 : Lancar uma BID a um lote numa sessao

-- Trigger 1 : Update Lot Price automatically when item are insterted and removed from ItemLot
-- Trigger 2 : 


/*###########
   Views
#############*/

/* V1: vw_active_sessions
List all active sessions
*/

DROP VIEW IF EXISTS vw_active_sessions;
CREATE VIEW vw_active_sessions AS 
SELECT * FROM `Session` WHERE  sessionState = 'active';

/*
  V2: vw_participant_details
  List all participants details
*/
DROP VIEW IF EXISTS vw_participant_details;
CREATE VIEW vw_participant_details AS 
SELECT 
  part.participantID AS "participantID",
  per.personName AS "participantName",
  per.personEmail AS "participantEmail",
  per.personNIF AS "participantNIF",
  fn_calculate_age(per.personBirthDate) AS "participantAge",
  per.personBirthDate AS "participantBirthDate",
  per.personGender AS "participantGender"
FROM Participant part
INNER JOIN `Person` per ON part.person_personID = per.personID;


/*
  V3: vw_active_lots
  List all lots on Sale
*/
DROP VIEW IF EXISTS vw_active_lots;
CREATE VIEW vw_active_lots AS
SELECT 
  lotId AS "lotId",
  lotName AS "lotName",
  lotState AS "lotState",
  lotPrice AS "lotPrice"
FROM Lot
WHERE lotId IN (SELECT lot_lotID FROM `SessionLot` WHERE session_sessionId  IN (SELECT sessionId FROM `vw_active_sessions` WHERE sessionState = 'active'));



/*####################
   Stored Procedures
######################*/

-- SPXXX : Add Lot to Session

DROP PROCEDURE IF EXISTS sp_add_lot_to_session;
DELIMITER $$
CREATE PROCEDURE sp_add_lot_to_session(IN lotId INT, IN sessionId INT)
BEGIN
    INSERT INTO SessionLot (lot_lotID, session_sessionId)
    VALUES (lotId, sessionId);
END$$
DELIMITER ;


-- SPXXX : Add Item to Lot

DROP PROCEDURE IF EXISTS sp_add_item_to_lot;
DELIMITER $$
CREATE PROCEDURE sp_add_item_to_lot(IN itemId INT, IN lotId INT)
BEGIN
    INSERT INTO ItemLot (item_itemId, lot_lotId)
    VALUES (itemId, lotId);
END$$
DELIMITER ;


-- SPXXX : ADD A BID
-- Description: Add a bid to a lot
-- IMPROVEMENT: Check if the bid is higher than the current bid, check if session is active

DROP PROCEDURE IF EXISTS sp_add_bid;
DELIMITER $$
CREATE PROCEDURE sp_add_bid(IN bidAmount INT, IN participantId INT, IN sessionId INT, IN lotId INT)
BEGIN
    INSERT INTO Bid (bidAmount, participant_participantId, session_sessionId, lot_lotId)
    VALUES (bidAmount, participantId, sessionId, lotId);
END$$
DELIMITER ;


-- - SPXXX: Start a session
-- Description: Start a session, set the state to active

DROP PROCEDURE IF EXISTS sp_start_session;
DELIMITER $$
CREATE PROCEDURE sp_start_session(IN p_sessionId INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_lotId INT;
    DECLARE lotCursor CURSOR FOR
        SELECT lot_lotId FROM `SessionLot` WHERE session_sessionId = p_sessionId;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Loop over all lots in the session and start them for sale
    OPEN lotCursor;
    loopLots: LOOP
        FETCH lotCursor INTO v_lotId;
        IF done THEN
            LEAVE loopLots;
        END IF;
        CALL sp_start_lot_sale(v_lotId);
    END LOOP;
    CLOSE lotCursor;

    -- Finally, mark the session as active
    UPDATE `Session`
    SET sessionState = 'active'
    WHERE sessionId = p_sessionId;
END$$
DELIMITER ;


-- - SPXXX: Close a session
-- Description: Close a session, set the state to complete

DROP PROCEDURE IF EXISTS sp_close_session;
DELIMITER $$

CREATE PROCEDURE sp_close_session(IN p_sessionId INT)
BEGIN

    -- Finally, mark the session as complete
    UPDATE `Session`
    SET sessionState = 'complete'
    WHERE sessionId = p_sessionId;

    CALL sp_create_transactions(p_sessionId);

    
END$$

DELIMITER ;


/* SPXXX: Create transactions
  Description: Create transactions for a session
  - For each lot in the session, if it has a bid related to it, mark lot as sold and create a transaction for it.
*/

DROP PROCEDURE IF EXISTS sp_create_transactions;
DELIMITER $$
CREATE PROCEDURE sp_create_transactions(IN p_sessionId INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_lotId INT;
    DECLARE v_maxBidId INT;
    DECLARE lotCursor CURSOR FOR 
        SELECT DISTINCT lot_lotId FROM Bid WHERE session_sessionId = p_sessionId;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN lotCursor;
    transaction_loop: LOOP
        FETCH lotCursor INTO v_lotId;
        IF done THEN
            LEAVE transaction_loop;
        END IF;

        -- Find the highest bid for the lot in this session
        SELECT bidId INTO v_maxBidId
        FROM Bid 
        WHERE session_sessionId = p_sessionId AND lot_lotId = v_lotId
        ORDER BY bidAmount DESC
        LIMIT 1;

        -- Create transaction for highest bid
        IF v_maxBidId IS NOT NULL THEN
            INSERT INTO `Transaction` (session_sessionId, lot_lotId, transactionAmount, participant_participantID, bid_bidId) 
            VALUES (p_sessionId, v_lotId, (SELECT bidAmount FROM Bid WHERE bidId = v_maxBidId), (SELECT participant_participantID FROM Bid WHERE bidId = v_maxBidId), v_maxBidId);

            CALL sp_mark_lot_as_sold(v_lotId);
        END IF;
    END LOOP;
    CLOSE lotCursor;
END$$
DELIMITER ;





/*
  SPXXX: Close a lot
  Description: Close a lot, set the state to sold
  - Remove lot from sessions that are not complete
  - Remove item from lots that are in sale
  - Mark items as sold
  - Mark lot as Sold

*/
DROP PROCEDURE IF EXISTS sp_mark_lot_as_sold;
DELIMITER $$
CREATE PROCEDURE sp_mark_lot_as_sold(IN p_lotId INT)
BEGIN

    

    DECLARE done INT DEFAULT FALSE;
    DECLARE v_bidId INT;
    DECLARE bidCursor CURSOR FOR 
        SELECT bidId FROM Bid WHERE lot_lotId = p_lotId AND session_sessionId IN (SELECT sessionId FROM `vw_active_sessions`);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Remove bid related to lot
    OPEN bidCursor;
    bid_loop: LOOP
        FETCH bidCursor INTO v_bidId;
        IF done THEN
            LEAVE bid_loop;
        END IF;
        CALL sp_delete_bid(v_bidId);
    END LOOP;
    CLOSE bidCursor;


    -- Mark items as sold
    UPDATE `Item`
    SET itemState = 'sold'
    WHERE itemID IN (
        SELECT item_itemID
        FROM ItemLot
        WHERE lot_lotId = p_lotId
    );
    
    -- Mark lot as sold
    UPDATE `Lot`
    SET lotState = 'sold'
    WHERE lotId = p_lotId;

    
    -- Remove item from lots that are in sale
    DELETE FROM `ItemLot`
    WHERE lot_lotId = p_lotId
      AND lot_lotId IN (
          SELECT lotId
          FROM `vw_active_lots`
      );

    
    -- Remove transactions related to lot & session
    DELETE FROM `Transaction`
    WHERE lot_lotId = p_lotId
      AND session_sessionId IN (
          SELECT sessionId
          FROM `vw_active_sessions`
      );

    -- Remove lot from sessions that are not complete
    DELETE FROM `SessionLot`
    WHERE lot_lotId = p_lotId
      AND session_sessionId IN (
          SELECT sessionId
          FROM `vw_active_sessions`
      );

    CALL sp_cleanup_sessions_and_lots();
    
END$$
DELIMITER ;


/*
  SPXXX: Start a lot for sale
  Description: Start a lot for sale, set the state to for_sale

*/
DROP PROCEDURE IF EXISTS sp_start_lot_sale;
DELIMITER $$
CREATE PROCEDURE sp_start_lot_sale(IN p_lotId INT)
BEGIN
   
    -- Mark items as on_sale
    UPDATE Item
    SET itemState = 'on_sale'
    WHERE itemID IN (
        SELECT item_itemID
        FROM ItemLot
        WHERE lot_lotId = p_lotId
    );
  
    -- Mark lot as on_sale
    UPDATE Lot
    SET lotState = 'on_sale'
    WHERE lotId = p_lotId;
    
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_cleanup_sessions_and_lots;
DELIMITER $$

CREATE PROCEDURE sp_cleanup_sessions_and_lots()
BEGIN
  -- Mark sessions as unscheduled if they no longer have lots
  UPDATE `Session` s
  SET s.sessionState = 'unscheduled'
  WHERE NOT EXISTS (
    SELECT 1 FROM SessionLot sl WHERE sl.session_sessionId = s.sessionId
  );

  -- Mark lots as not sold if no longer part of any session
  UPDATE `Lot` l
  SET l.lotState = 'not_sold'
  WHERE NOT EXISTS (
    SELECT 1 FROM SessionLot sl WHERE sl.lot_lotId = l.lotId
  );
END$$
DELIMITER ;


/*###########
    Functions
#############*/



/* F1: fn_can_delete_session
Return TRUE if the session can be deleted
*/

DROP FUNCTION IF EXISTS fn_can_delete_session;
DELIMITER $$
CREATE FUNCTION fn_can_delete_session(sessionId INT) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE dependentCount INT DEFAULT 0;

  -- Check in ParticipantSession
  SELECT COUNT(*) INTO dependentCount
  FROM ParticipantSession
  WHERE session_sessionId = sessionId;

  IF dependentCount > 0 THEN
    RETURN FALSE;
  END IF;

  -- Check in Bid
  SELECT COUNT(*) INTO dependentCount
  FROM Bid
  WHERE session_sessionId = sessionId;

  IF dependentCount > 0 THEN
    RETURN FALSE;
  END IF;

  -- Check in SessionLot
  SELECT COUNT(*) INTO dependentCount
  FROM SessionLot
  WHERE session_sessionId = sessionId;

  IF dependentCount > 0 THEN
    RETURN FALSE;
  END IF;

  -- If no dependencies found, session can be deleted
  RETURN TRUE;
END$$
DELIMITER ;


/* F2: fn_calculate_age
Return the age of a person
*/
DROP FUNCTION IF EXISTS fn_calculate_age;
DELIMITER $$
CREATE FUNCTION fn_calculate_age(birthDate DATE) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = YEAR(CURDATE()) - YEAR(birthDate);
    
    -- If the current date is before the birthday this year, subtract 1
    IF (MONTH(CURDATE()) < MONTH(birthDate)) 
       OR (MONTH(CURDATE()) = MONTH(birthDate) AND DAY(CURDATE()) < DAY(birthDate)) THEN
        SET age = age - 1;
    END IF;
    
    RETURN age;
END$$

DELIMITER ;


/* TO COMPLETE NOT WORKING */
DROP FUNCTION IF EXISTS fn_isItemOnActiveSession;
DELIMITER $$
CREATE FUNCTION fn_isItemOnActiveSession(itemId INT, sessionId INT) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN EXISTS (SELECT * FROM ItemLot WHERE item_itemId = itemId AND session_sessionId = sessionId);
END$$
DELIMITER ;


/* ##### 
  TRIGGERS
  #####*/


/*###########
    Functions
#############*/

/* F1: fn_can_delete_session(sessionId) re
 Description: Verifica se uma sessao pode ser excluida, caso nao tenha dependencias como participantes, bids, lotes
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


/* F2: fn_calculate_age(birthDate)
Description: Calcula a idade a partir da data de nascimento
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

/*######################
        ENUNCIADO
########################*/


/* SP1 : sp_criar_leilao (sessionName, location_locationId, organization_organizationId, auctioneer_auctioneerId, timeslot_timeSlotId)
 
Cria um novo leilão/evento, enviando todos os dados necessários à definição do mesmo;
Criar uma nova SESSION.

# Melhoria futura: Validar se existe uma sessao com a mesma localizacao e mesmo timeslot, nesse caso retornar erro
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


/* SP2 :  sp_adicionar_participante(participantId, sessionId)

Adiciona uma pessoa à lista de participantes que irão fazer parte do leilão indicado;

# Melhoria futura: Validar se participante já está numa sessao ao mesmo tempo, nesse caso ignorar 
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


/* SP3 : sp_close_session (sessionId)

Fechar a sessão indicada, e criar as transações correspondentes aos leilões ativos nessa sessão.

*/


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



/* SP4 : sp_remover_leilao(sessionId, forceDelete)

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
        


/* SP5 :  sp_clonar_leilao(sessionId)

Cria um novo leilão/evento com uma cópia de todos os dados existentes no leilão/evento indicada como parâmetro. 
A única exceção é que, à descrição do leilão, deverá ser adicionada a string " --- COPIA (a preencher)".
*/

DROP PROCEDURE IF EXISTS sp_clonar_leilao;
DELIMITER $$
CREATE PROCEDURE sp_clonar_leilao(IN p_sessionId INT, OUT newSessionId INT)
BEGIN

  INSERT INTO `Session` (sessionName, location_locationId, organization_organizationId, auctioneer_auctioneerId, timeslot_timeSlotId)
  SELECT 
    CONCAT(sessionName, '  --- COPIA (a preencher)'),
    location_locationId,
    organization_organizationId,
    auctioneer_auctioneerId,
    timeslot_timeSlotId
  FROM `Session`
  WHERE sessionId = p_sessionId;

  SET newSessionId = LAST_INSERT_ID();


  INSERT INTO SessionLot (session_sessionId, lot_lotId)
  SELECT 
    newSessionId,
    lot_lotId
  FROM SessionLot
  WHERE session_sessionId = p_sessionId;


  INSERT INTO ParticipantSession (participant_participantId, session_sessionId)
  SELECT 
    participant_participantId,
    newSessionId
  FROM ParticipantSession
  WHERE session_sessionId = p_sessionId;

END$$
DELIMITER ;

/*###########
    DELETE
#############*/


/* SP6 : sp_delete_session (p_sessionId)
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
  Delete machineCategory and all related data, set item.machineCategory_machineCategoryId to NULL, 
  set itemHistory.machineCategory_machineCategoryId to NULL
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
  Delete muscleCategory and all related data, set item.muscleCategory_muscleCategoryId to NULL, 
  set itemHistory.muscleCategory_muscleCategoryId to NULL
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

/* 
  T1 : result_change
  Diferente do enunciado pois uma session nao tem um valor mas sim o seu estado.
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
  T2 : result_delete
   Trigger utilizado para registar o apagar de uma sessao
*/

DROP TRIGGER IF EXISTS result_delete;
DELIMITER $$
CREATE TRIGGER result_delete AFTER DELETE ON `Session` FOR EACH ROW
BEGIN
    INSERT INTO `tbl_delete_logs` (session_sessionId, session_sessionName, logMessage)
    VALUES (OLD.sessionId, OLD.sessionName, 'Session deleted');
END$$
DELIMITER ; 




/*######################
        CUSTOM 
########################
(Enunciado ponto 2 - 1.2)
*/

/*###########
   Views
#############*/

/* V1: vw_active_sessions
  Desctription: Mostrar todas as sessões ativas, ou seja, com o estado 'active'
*/

DROP VIEW IF EXISTS vw_active_sessions;
CREATE VIEW vw_active_sessions AS 
SELECT * FROM `Session` WHERE  sessionState = 'active';

/*
  V2: vw_participant_details
  Description: Mostrar todos os detalhes de um participante, incluindo o nome, email, NIF, idade, data de nascimento e genero que pertencem ao participante
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
  Description: Mostrar todos os lotes em venda, ou seja, que pertencam a uma sessao ativa
*/
DROP VIEW IF EXISTS vw_active_lots;
CREATE VIEW vw_active_lots AS
SELECT 
  lotId AS "lotId",
  lotName AS "lotName",
  lotState AS "lotState",
  lotPrice AS "lotPrice"
FROM Lot
WHERE lotId IN (SELECT lot_lotID FROM `SessionLot` WHERE session_sessionId  IN (SELECT sessionId FROM `vw_active_sessions`));


/* V4: vw_highest_bids_per_lot
  Description: Mostrar todas as licitacoes mais altas para cada lote
*/

DROP VIEW IF EXISTS vw_highest_bids_per_lot;
CREATE VIEW vw_highest_bids_per_lot AS
SELECT 
    b.lot_lotId,
    l.lotName,
    b.session_sessionId,
    s.sessionName,
    b.bidId,
    b.bidAmount,
    b.participant_participantID,
    p.participantName
FROM `Bid` b
JOIN `Lot` l ON l.lotId = b.lot_lotId
JOIN `Session` s ON s.sessionId = b.session_sessionId
JOIN `vw_participant_details` p ON p.participantId = b.participant_participantId
WHERE b.bidAmount = (
    SELECT MAX(b2.bidAmount)
    FROM Bid b2
    WHERE b2.lot_lotId = b.lot_lotId
      AND b2.session_sessionId = b.session_sessionId
);

/* 
V5: vw_orphan_lots
Description: Mostrar todos os lotes sem sessao nenhuma ou sem sessao ativa ou futura
*/

DROP VIEW IF EXISTS vw_orphan_lots;
CREATE VIEW vw_orphan_lots AS
SELECT 
    l.lotId,
    l.lotName,
    l.lotState
FROM Lot l
LEFT JOIN SessionLot sl ON sl.lot_lotId = l.lotId
LEFT JOIN Session s ON s.sessionId = sl.session_sessionId
WHERE s.sessionState IS NULL OR s.sessionState NOT IN ('complete', 'active', 'scheduled');

-- V6: vw_item_lot_details
DROP VIEW IF EXISTS vw_item_lot_details;
CREATE VIEW vw_item_lot_details AS
SELECT
    l.lotId AS "lotId",
    l.lotName AS "lotName",
    l.lotState AS "lotState",
    i.itemId AS "itemId",
    i.itemName AS "itemName",
    i.itemPrice AS "itemPrice",
    i.itemCondition AS "itemCondition",
    i.itemState AS "itemState"
FROM Item i
JOIN ItemLot il ON il.item_itemId = i.itemId
JOIN Lot l ON l.lotId = il.lot_lotId
ORDER BY l.lotId;

/*####################
   Stored Procedures
######################*/

-- SP20: sp_add_lot_to_session(lotId, sessionId)
-- Description: Adiciona um lote a uma sessao

DROP PROCEDURE IF EXISTS sp_add_lot_to_session;
DELIMITER $$
CREATE PROCEDURE sp_add_lot_to_session(IN lotId INT, IN sessionId INT)
BEGIN
    INSERT INTO SessionLot (lot_lotID, session_sessionId)
    VALUES (lotId, sessionId);
END$$
DELIMITER ;


-- SP21: sp_add_item_to_lot(itemId, lotId)
-- Description: Adiciona um item a um lote

DROP PROCEDURE IF EXISTS sp_add_item_to_lot;
DELIMITER $$
CREATE PROCEDURE sp_add_item_to_lot(IN itemId INT, IN lotId INT)
BEGIN
    INSERT INTO ItemLot (item_itemId, lot_lotId)
    VALUES (itemId, lotId);
END$$
DELIMITER ;


-- SP22: sp_add_bid(bidAmount, participantId, sessionId, lotId)
-- Description: Adiciona uma bid a um lote numa sessao
-- IMPROVEMENT: Check if the bid is higher than the current bid, check if session is active

DROP PROCEDURE IF EXISTS sp_add_bid;
DELIMITER $$
CREATE PROCEDURE sp_add_bid(IN bidAmount INT, IN participantId INT, IN sessionId INT, IN lotId INT)
BEGIN
    INSERT INTO Bid (bidAmount, participant_participantId, session_sessionId, lot_lotId)
    VALUES (bidAmount, participantId, sessionId, lotId);
END$$
DELIMITER ;


-- SP23: sp_start_session(sessionId)
-- Description: Inicia uma sessao, marcando todos os seus lotes como on_sale

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





-- SP24: sp_create_transactions(sessionId)
-- Description: Cria transacoes para todas as bids em uma sessao

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
-- SP25: sp_mark_lot_as_sold(lotId)
Description: Marca um lote como vendido, removendo-o de todas as sessoes que nao estao completas 
removendo-o de todos os items que estao em leilao, marcando-os como vendidos.
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


-- SP26: sp_start_lot_sale(lotId)
-- Description: Inicia uma sessao, marcando todos os seus lotes como on_sale
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


-- SP27: sp_cleanup_sessions_and_lots()
-- Description: Limpa as sessoes e lotes nao utilizados
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



-- SP28: sp_update_lot_price(p_lotId)
-- Description: Atualiza o preco de um lote com os precos de todos os seus items
DROP PROCEDURE IF EXISTS sp_update_lot_price;
DELIMITER $$

CREATE PROCEDURE sp_update_lot_price(IN p_lotId INT)
BEGIN
    UPDATE Lot
    SET lotPrice = (
        SELECT SUM(i.itemPrice)
        FROM `Item` i
        JOIN `ItemLot` il ON i.itemID = il.item_itemID
        WHERE il.lot_lotID = p_lotId
    ) WHERE lotId = p_lotId;
END$$
DELIMITER ;





/* ##### 
  TRIGGERS
  #####*/

-- T3: item_update
-- Description: Atualiza o preço de um lote quando um item adicionado ou removido
DROP TRIGGER IF EXISTS item_update;
DELIMITER $$
CREATE TRIGGER item_update AFTER UPDATE ON Item
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_lotId INT;
    DECLARE lotCursor CURSOR FOR
        SELECT lot_lotId FROM ItemLot WHERE item_itemID = NEW.itemID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN lotCursor;
    read_loop: LOOP
        FETCH lotCursor INTO v_lotId;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL sp_update_lot_price(v_lotId);
    END LOOP;
    CLOSE lotCursor;

END$$
DELIMITER ;


-- T4: item_lot_insert 
-- Description: Atualiza o preço de um lote quando um item adicionado
DROP TRIGGER IF EXISTS item_lot_insert;
DELIMITER $$
CREATE TRIGGER item_lot_insert AFTER INSERT ON ItemLot
FOR EACH ROW
BEGIN
    CALL sp_update_lot_price(NEW.lot_lotId);
END$$
DELIMITER ;


-- T5: item_lot_delete
-- Description: Atualiza o preço de um lote quando um item removido
DROP TRIGGER IF EXISTS item_lot_delete;
DELIMITER $$
CREATE TRIGGER item_lot_delete AFTER DELETE ON ItemLot
FOR EACH ROW
BEGIN
    CALL sp_update_lot_price(OLD.lot_lotId);
END$$
DELIMITER ;
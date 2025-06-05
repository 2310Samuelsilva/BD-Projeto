





/*######################
        ENUNCIADO
########################*/


/* SP1 : sp_criar_leilao

Cria um novo leilão/evento, enviando todos os dados necessários à definição do mesmo;
Criar uma nova SESSION.

#IDEIA: Validar se existe uma sessao com a mesma localizacao e mesmo timeslot, nesse caso retornar erro
*/

DELIMITER $$
CREATE PROCEDURE sp_criar_leilao(IN sessionName VARCHAR(100), 
        IN location_locationId INT,
        IN organization_orgId INT,
        IN auctioneer_aucId INT,
        IN timeslot_timeSlotId INT)
BEGIN

    INSERT INTO Session (sessionName, location_locationId, organization_orgId, auctioneer_aucId, timeslot_timeSlotId)
    VALUES (sessionName, location_locationId, organization_orgId, auctioneer_aucId timeslot_timeSlotId);
END$$
DELIMITER ; 


/* SP2 :  sp_adicionar_participante(id_leilao, …)

Adiciona uma pessoa à lista de participantes que irão fazer parte do leilão indicado;

#IDEA: Validar se participante já está numa sessao, nesse caso ignorar 
*/

DELIMITER $$
CREATE PROCEDURE sp_adicionar_participante(
        IN participantId INT,
        IN sessionId INT)
BEGIN 

    INSERT INTO ParticipantSession (participant_participantID, session_sessionId)
    VALUES (participantId, sessionId);

END$$
DELIMITER ;


/* SP3 : sp_registar_resultado(id_leilao, id_participante, …) 

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

DELIMITER $$
CREATE PROCEDURE sp_remover_leilao(IN sessionId INT, IN force BOOLEAN DEFAULT FALSE)
BEGIN
        IF CanDeleteSession(sessionId) OR force THEN
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

CREATE PROCEDURE sp_clonar_leilao(IN sessionId INT)
BEGIN

  DECLARE newSessionId INT;

  INSERT INTO `Session` (sessionName, location_locationId, organization_orgId, auctioneer_aucId, timeslot_timeSlotId)
  SELECT 
    CONCAT(sessionName, '  --- COPIA (a preencher)'),
    location_locationId,
    organization_orgId,
    auctioneer_aucId,
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
 Apagar uma sessao e todos dados relacionados com a mesma 
*/

DELIMITER $$
CREATE PROCEDURE sp_delete_session(IN sessionId INT)
BEGIN
    DELETE FROM ParticipantSession WHERE session_sessionId = sessionId;
    DELETE FROM SessionLot WHERE session_sessionId = sessionId;
    DELETE FROM Bid WHERE session_sessionId = sessionId;
    DELETE FROM Session WHERE session_sessionId = sessionId;
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
-- View 2 : 
-- View 3 : Detalhes de um Item
-- View 4 : Taxa de sucesso (lotes vendidos vs. não vendidos) por sessão
-- View 5 : Leiloeiros com mais sessões realizadas ou maior volume de vendas

-- Function 1 : IsItemOnActiveSession
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
   Viewes
#############*/

/* V1: ActiveSessions
List all active sessions
*/
CREATE VIEW ActiveSessions AS 
SELECT * FROM Session WHERE  LOWERCASE(sessionState) = 'active';



/*####################
   Stored Procedures
######################*/


/*###########
    Functions
#############*/

CREATE FUNCTION IsItemOnActiveSession(IN itemId INT, IN sessionId INT) RETURNS BOOLEAN
BEGIN
    RETURN EXISTS (SELECT * FROM ItemLot WHERE item_itemId = itemId AND session_sessionId = sessionId);
END


/* F1: CanDeleteSession
Return TRUE if the session can be deleted
*/

DELIMITER $$
CREATE FUNCTION CanDeleteSession(sessionId INT) RETURNS BOOLEAN
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
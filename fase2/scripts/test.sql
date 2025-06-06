
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `Session`;
-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

CALL sp_criar_leilao('Session1', 1, 1, 1, 1);
CALL sp_adicionar_participante(1, 1);

CALL sp_add_lot_to_session(1,1);
CALL sp_add_lot_to_session(2,1);

CALL sp_add_item_to_lot(1, 1);
CALL sp_add_item_to_lot(2, 1);

CALL sp_add_bid(100.00, 1, 1, 1);
CALL sp_add_bid(200.00, 2, 1, 1);

CALL sp_remover_leilao(1, 1);


DROP PROCEDURE IF EXISTS sp_delete_session;
DELIMITER $$
CREATE PROCEDURE sp_delete_session(IN sessionId INT)
BEGIN
    DELETE FROM ParticipantSession WHERE session_sessionId = sessionId;
    DELETE FROM Bid WHERE session_sessionId = sessionId;
    DELETE FROM SessionLot WHERE session_sessionId = sessionId;
    DELETE FROM `Session` WHERE sessionId = sessionId;
END$$
DELIMITER ;
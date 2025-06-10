
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

CALL sp_start_session(1);
CALL sp_start_session(2);

CALL sp_close_session(1);
CALL sp_create_transactions(1);
CALL sp_mark_lot_as_sold(1);

CALL sp_cleanup_sessions_and_lots();

SELECT bidId FROM Bid WHERE lot_lotId = 1 AND session_sessionId IN (SELECT sessionId FROM `vw_active_sessions`);
CALL sp_delete_bid(2);
CALL sp_delete_session(2);


CALL sp_add_bid(999.00, 1, 2, 1);

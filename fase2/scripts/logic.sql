

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




/*######################
        ENUNCIADO
########################*/


/* SP1 : sp_criar_leilao

Cria um novo leilão/evento, enviando todos os dados necessários à definição do mesmo;
*/

/* SP2 :  sp_adicionar_participante(id_leilao, …)

Adiciona uma pessoa à lista de participantes que irão fazer parte do leilão indicado;
*/


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

/* SP5 :  sp_clonar_leilao(id_leilao, …) 

Cria um novo leilão/evento com uma cópia de todos os dados existentes no leilão/evento indicada como parâmetro. 
A única exceção é que, à descrição do leilão, deverá ser adicionada a string " --- COPIA (a preencher)".
*/

/*###########
    DELETE
#############*/

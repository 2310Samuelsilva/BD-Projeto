use ipm_bidding_system;
-- Q1.1
-- Listagem de participantes femininos que participaram
SELECT 
    participantId AS "ID do Participante",
    participantName AS "Nome do Participante",
    participantEmail AS "Email do Participante",
    participantAge AS "Idade do Participante",
    participantBirthDate AS "Data de Nascimento do Participante",
    participantGender AS "Genero do Participante",
    participantNIf AS "NIF do Participante"
 FROM vw_participant_details WHERE participantGender='female' ORDER BY participantName;



-- Q1.2
-- Listagem de participantes com mais de 30 anos

SELECT 
    participantId AS "ID do Participante",
    participantName AS "Nome do Participante",
    participantEmail AS "Email do Participante",
    participantAge AS "Idade do Participante",
    participantBirthDate AS "Data de Nascimento do Participante",
    participantGender AS "Genero do Participante",
    participantNIf AS "NIF do Participante"
 FROM vw_participant_details WHERE participantAge > 30 ORDER BY participantName;


 -- Q2.
 -- Listagem de Sessoes ativas e com mais de 3 lotes
SELECT s.*
FROM `Session` s
WHERE s.sessionId IN (SELECT sessionId from vw_active_sessions)
  AND (
      SELECT COUNT(*)
      FROM SessionLot sl
      WHERE sl.session_sessionId = s.sessionId
  ) > 3;
 
-- Q3.1
-- número de licitações por sessão e por lote e a sua média
SELECT 
    session_sessionId AS "ID da Sessão",
    lot_lotId AS "ID do Lote",
    COUNT(*) AS "Número de Licitações",
    AVG(bidAmount) AS "Média do valor das licitações"
FROM Bid
GROUP BY session_sessionId, lot_lotId
ORDER BY session_sessionId, lot_lotId;


-- Q3.2
-- Licitações feitas na sessão 1
SELECT 
    b.bidID AS "ID da Bid",
    b.bidAmount AS "Valor da Bid",
    b.participant_participantID AS "ID do Participante",
    p.personName AS "Participante",
    l.lotName AS "Lote"
FROM Bid b
JOIN Participant pt ON b.participant_participantID = pt.participantID
JOIN Person p ON pt.person_personID = p.personID
JOIN Lot l ON b.lot_lotId = l.lotId
WHERE b.session_sessionId = 1
ORDER BY b.bidAmount DESC;

-- Q3.3 
-- Maior licitação por lote
SELECT 
    b.lot_lotId AS "ID do Lote",
    l.lotName AS "Nome do Lote",
    MAX(b.bidAmount) AS "Maior Licitação"
FROM Bid b
JOIN Lot l ON b.lot_lotId = l.lotId
GROUP BY b.lot_lotId;

 -- Q4.1
 -- Itens que nunca estiveram em nenhum lote
 SELECT 
    itemId AS "ID do Item",
    itemName AS "Nome do Item",
    itemPrice AS "Preço do Item",
    itemCondition AS "Condição do Item",
    itemState AS "Estado do Item"
FROM `Item`
WHERE itemId NOT IN (
  SELECT item_itemID FROM ItemLot
);

-- Q4.2
-- Itens que pretenceram a mais do que um lote
SELECT 
    i.itemId AS "ID do Item",
    i.itemName AS "Nome do Item",
    COUNT(il.lot_lotID) AS "Número de lotes que pertenceu"
FROM Item i
JOIN ItemLot il ON i.itemId = il.item_itemID
GROUP BY i.itemId, i.itemName
HAVING COUNT(il.lot_lotID) > 1
ORDER BY COUNT(il.lot_lotID);

-- 4.b
-- bens que não foram vendidos em qualquer leilão/sessão
SELECT 
    i.itemId AS "ID do Item",
    i.itemName AS "Nome do Item",
    i.itemPrice AS "Preço do Item",
    i.itemCondition AS "Condição do Item",
    i.itemState AS "Estado do Item"
FROM Item i
WHERE NOT EXISTS (
    SELECT 1
    FROM ItemLot il
    JOIN Bid b ON il.lot_lotID = b.lot_lotID
    WHERE il.item_itemID = i.itemId
) AND i.itemState != "sold"; -- meti isto porque testei alterar o estado de itens para sold e como não adicionei bids, apareciam na mesma

-- Q5.1
-- Lista com o número médio, mínimo, máximo e desvio padrão dos bens vendidos por leilão/evento que tenham como categoria de maquina 1
SELECT 
    AVG(num_items_sold) AS "Média",
    MIN(num_items_sold) AS "Mínimo" ,
    MAX(num_items_sold) AS "Máximo",
    STDDEV(num_items_sold) AS "Desvio Padrão"
FROM (
    SELECT 
        s.sessionId,
        COUNT(DISTINCT i.itemId) AS num_items_sold
    FROM Session s
    JOIN SessionLot sl ON sl.session_sessionId = s.sessionId
    JOIN Lot l ON l.lotId = sl.lot_lotId
    JOIN ItemLot il ON il.lot_lotID = l.lotId
    JOIN Item i ON i.itemId = il.item_itemID
    WHERE i.itemState = 'sold' 
      AND i.machineCategory_machineCategoryId = 1
    GROUP BY s.sessionId
) AS subquery;

-- Q5.2
-- Lista com o número médio, mínimo, máximo e desvio padrão dos bens vendidos por leilão/evento, das sessões ativas
-- NOTA: aqui o state da session é se está ativa ou não? como tens "new" não percebi...
SELECT
    AVG(num_items_sold) AS "Média",
    MIN(num_items_sold) AS "Mínimo" ,
    MAX(num_items_sold) AS "Máximo",
    STDDEV(num_items_sold) AS "Desvio Padrão"
FROM (
  SELECT 
    s.sessionId,
    COUNT(DISTINCT i.itemId) AS num_items_sold
  FROM `Session` s
  JOIN `SessionLot` sl ON sl.session_sessionId = s.sessionId
  JOIN `Lot` l ON l.lotId = sl.lot_lotId
  JOIN `ItemLot` il ON il.lot_lotID = l.lotId
  JOIN `Item` i ON i.itemId = il.item_itemID
  WHERE i.itemState = 'sold' 
    AND s.sessionId IN (SELECT sessionId FROM `vw_active_sessions`)
  GROUP BY s.sessionId
) AS subquery;

-- Q6 

-- Q7
-- Lista de participantes individuais que não participaram em qualquer leilão
SELECT
    person.personName AS "Nome do Participante",
    person.personEmail AS "Email do Participante",
    TIMESTAMPDIFF(YEAR, person.personBirthDate, CURDATE()) AS "Idade do Participante",
    person.personBirthDate AS "Data de Nascimento do Participante",
    person.personGender AS "Gênero do Participante",
    person.personNIF AS "NIF do Participante"
FROM Person person
LEFT JOIN Auctioneer a ON person.personID = a.person_personID
LEFT JOIN Participant pt ON person.personID = pt.person_personID
WHERE a.auctioneerId IS NULL AND pt.participantID IS NULL;

-- Q8
-- Lista dos participantes de cada leilão com identificação das licitações no leilão/evento e respetivas características de cada licitação
SELECT 
    s.sessionId AS "ID da Sessão",
    s.sessionName AS "Nome da Sessão",
    p.personID AS "ID do Participante",
    p.personName AS "Nome do Participante",
    p.personEmail AS "Email do participante",
    b.bidId AS "ID da Licitação",
    b.bidAmount AS "Valor da Licitação",
    b.createdAt AS "Hora da Licitação",
    l.lotId AS "ID do Lote",
    l.lotName AS "Nome do Lote",
    l.lotPrice AS "Preço inicial do Lote",
    l.lotState AS "Estado do Lote",
    COUNT(i.itemId) AS "Número de Itens do Lote"
FROM 
    Session s
JOIN 
    ParticipantSession ps ON s.sessionId = ps.session_sessionId
JOIN 
    Participant pt ON ps.participant_participantID = pt.participantID
JOIN 
    Person p ON pt.person_personID = p.personID
JOIN 
    Bid b ON (b.participant_participantID = pt.participantID AND b.session_sessionId = s.sessionId)
JOIN 
    SessionLot sl ON (s.sessionId = sl.session_sessionId AND b.lot_lotId = sl.lot_lotId)
JOIN 
    Lot l ON sl.lot_lotId = l.lotId
LEFT JOIN 
    ItemLot il ON l.lotId = il.lot_lotID
LEFT JOIN 
    Item i ON il.item_itemID = i.itemId
GROUP BY 
    s.sessionId, p.personID, b.bidId, l.lotId
ORDER BY 
    s.sessionId, p.personID, b.createdAt;
    
-- Q9
-- Top 5 dos leilões com maior número de participantes, entre os 18 e os 80 anos, agrupada por ano e tendo como base os últimos três anos, 
SELECT 
    auction_year As "Ano do Leilão",
    auction_id "Id do Leilão",
    auction_name "Nome do Leilão",
    total_participants "Nº de participantes",
    average_participant_age "Média de Idades dos Participantes",
    youngest_participant "Idade do Participante mais novo",
    oldest_participant "Idade do participante mais velho"
FROM (
    SELECT 
        YEAR(s.createdAt) AS auction_year,
        s.sessionId AS auction_id,
        s.sessionName AS auction_name,
        COUNT(DISTINCT pt.participantID) AS total_participants,
        ROUND(AVG(TIMESTAMPDIFF(YEAR, p.personBirthDate, CURDATE())), 0) AS average_participant_age,
        MIN(TIMESTAMPDIFF(YEAR, p.personBirthDate, CURDATE())) AS youngest_participant,
        MAX(TIMESTAMPDIFF(YEAR, p.personBirthDate, CURDATE())) AS oldest_participant,
        @rank := IF(@current_year = YEAR(s.createdAt), @rank + 1, 1) AS rank_in_year,
        @current_year := YEAR(s.createdAt) AS dummy
    FROM 
        Session s
    JOIN 
        ParticipantSession ps ON s.sessionId = ps.session_sessionId
    JOIN 
        Participant pt ON ps.participant_participantID = pt.participantID
    JOIN 
        Person p ON pt.person_personID = p.personID,
        (SELECT @rank := 0, @current_year := NULL) AS vars
    WHERE 
        s.createdAt >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
        AND TIMESTAMPDIFF(YEAR, p.personBirthDate, CURDATE()) BETWEEN 18 AND 80
    GROUP BY 
        YEAR(s.createdAt), s.sessionId, s.sessionName
    ORDER BY 
        YEAR(s.createdAt), COUNT(DISTINCT pt.participantID) DESC
) AS ranked
WHERE 
    rank_in_year <= 5
ORDER BY 
    auction_year DESC, 
    total_participants DESC;

-- Q10
-- Histórico de lances de cada participante por ordem cronológica
SELECT 
    p.personName AS 'Participante',
    s.sessionName AS 'Leilão',
    l.lotName AS 'Lote',
    b.bidAmount AS 'Valor do Lance',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i') AS 'Data/Hora',
    DENSE_RANK() OVER(PARTITION BY p.personID ORDER BY b.createdAt) AS 'Nº do lance'
FROM 
    Bid b
JOIN 
    Participant pt ON b.participant_participantID = pt.participantID
JOIN 
    Person p ON pt.person_personID = p.personID
JOIN 
    Session s ON b.session_sessionId = s.sessionId
JOIN 
    Lot l ON b.lot_lotId = l.lotId
ORDER BY 
    p.personName, 
    b.createdAt;

-- Q11
-- Itens mais populares (com maior número de licitações)
SELECT 
    i.itemName AS 'Item',
    mc.machineCategoryName AS 'Categoria',
    COUNT(b.bidId) AS 'Número de Lances',
    MAX(b.bidAmount) AS 'Maior Lance',
    AVG(b.bidAmount) AS 'Média de Lances'
FROM 
    Item i
JOIN 
    ItemLot il ON i.itemId = il.item_itemID
JOIN 
    Lot l ON il.lot_lotID = l.lotId
JOIN 
    Bid b ON l.lotId = b.lot_lotId
JOIN 
    MachineCategory mc ON i.machineCategory_machineCategoryId = mc.machineCategoryId
GROUP BY 
    i.itemId
HAVING 
    COUNT(b.bidId) > 0
ORDER BY 
    COUNT(b.bidId) DESC
LIMIT 10;

-- Q12
-- Itens com categorias e subcategorias
SELECT 
    i.itemId AS 'ID Item',
    i.itemName AS 'Nome Item',
    CASE 
        WHEN pai.muscleCategoryName IS NOT NULL AND filho.muscleCategoryName IS NOT NULL 
        THEN pai.muscleCategoryName
        ELSE COALESCE(pai.muscleCategoryName, filho.muscleCategoryName)
    END AS 'Categoria',
    CASE 
        WHEN pai.muscleCategoryName IS NOT NULL AND filho.muscleCategoryName IS NOT NULL 
        THEN filho.muscleCategoryName
        ELSE NULL
    END AS 'Subcategoria',
    i.itemPrice AS 'Preço',
    i.itemCondition AS 'Condição'
FROM 
    Item i
LEFT JOIN 
    MuscleCategory filho ON i.muscleCategory_muscleCategoryId = filho.muscleCategoryId
LEFT JOIN 
    MuscleCategory pai ON filho.parentMuscleCategoryId = pai.muscleCategoryId
ORDER BY 
    i.itemid;
    
-- Q13.1
-- Média do valor das licitações por leilão, para leilões com mais de 2 licitações
SELECT 
    s.sessionId,
    s.sessionName,
    bid_stats.avg_bids_per_lot,
    bid_stats.total_bids
FROM Session s
JOIN (
    SELECT 
        sl.session_sessionId,
        AVG(bid_count) AS avg_bids_per_lot,
        SUM(bid_count) AS total_bids
    FROM SessionLot sl
    JOIN (
        SELECT 
            lot_lotID, 
            COUNT(*) AS bid_count
        FROM Bid
        GROUP BY lot_lotID
    ) lot_bids ON sl.lot_lotId = lot_bids.lot_lotID
    GROUP BY sl.session_sessionId
    HAVING SUM(bid_count) > 2
) bid_stats ON s.sessionId = bid_stats.session_sessionId;

-- Q13.2
-- Itens com preço superior à média do preço dos itens da sua categoria
SELECT 
    i.itemId AS "ID do Item",
    i.itemName AS "Nome do Item",
    i.itemPrice AS "Preço do Item",
    i.machineCategory_machineCategoryId AS "ID da Categoria",
    (SELECT ROUND(AVG(itemPrice), 2)
     FROM Item 
     WHERE machineCategory_machineCategoryId = i.machineCategory_machineCategoryId) AS "Média do Preço dos Itens da Categoria"
FROM Item i
WHERE i.itemPrice > (
    SELECT AVG(itemPrice) 
    FROM Item 
    WHERE machineCategory_machineCategoryId = i.machineCategory_machineCategoryId
);
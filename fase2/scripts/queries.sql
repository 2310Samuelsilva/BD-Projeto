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
 FROM ParticipantDetails WHERE participantGender='male';



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
 FROM ParticipantDetails WHERE participantAge > 30;


 --Q2.
 -- Listagem de Sessoes ativas e com mais de 3 lotes
SELECT s.*
FROM `Session` s
WHERE s.sessionId IN (SELECT sessionId FROM ActiveSessions)
  AND (
      SELECT COUNT(*)
      FROM SessionLot sl
      WHERE sl.session_sessionId = s.sessionId
  ) > 3;
 
 
  FROM SessionDetails WHERE numLots > 3
-- Q1.1
-- Listagem de participantes femininos que participaram nos leilões
SELECT 
    participantId AS "ID do Participante",
    participantName AS "Nome do Participante",
    participantEmail AS "Email do Participante",
    participantAge AS "Idade do Participante",
    participantBirthDate AS "Data de Nascimento do Participante",
    participantGender AS "Genero do Participante",
    participantNIf AS "NIF do Participante"
 FROM ParticipantDetails WHERE participantGender='female';
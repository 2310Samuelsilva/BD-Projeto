""""
Autor: Samuel Silva N202200315

Projeto de DB 2025
"""


# Objetivo

- Criar DB para gerir leilao

**Tema:** Ginásio

# !!! DUVIDAS !!!

- Que tipo de indicadores estatisticos e como? R: Estás a falar do ponto 2.b)? Penso que seja por exemplo quantos lotes/bens foram licitados e percentagem que foi vendida ou não
mas é melhor falar com o professor para ter certeza
- Que tipo de entidades faltam?
- Generalização está em falta, é um requisito, possivelmente pessoas (participante e leiloeiro)
- Como implementar a ficha técnica do item?
- Como gerir ITEM ou LOTES, devemos assumir que mesmo que um leilao seja feito com 1 item, este terá de ser um LOT apenas com 1 item? sim acho que sim, fazemos tipo, um leilão
tem um ou vários LOTs e tem obrigatóriamente que ter pelo menos um LOt. E um LOT tem um ou vários itens e tem que ter pelo menos um item.
- É possível comprar apenas 1 item que esteja num lote? Acho que não e iria complocar bastante, acho que um lote deve ser licitado como um todo, se não o item seria licitado 
à parte.

## IDEIAS ###

Indicadores estatisticos:
    - Preco? Preço a que começam as licitações ya
    - Quantidade de bids? não sei se é necessário mas não é mal pensado
    - Categoria que mais vende?
    - Numero de participantes? participantes tas a falar de nº de pessoas "presente" para licitar ou o nº de pessoas que efetivamente fez uma bid?



## Ficha técnica sobre item, historico

- registo de transações dos últimos 3 anos (preço, ano de venda/compra... que mais? 
    - indicadores sobre preços de venda anteriores e participação em leilões --> preço de venda anteriores dava para meter no registo de transações! depois a participação
	em leilões podia ser tipo um atriburo da transação (tou a assumir que a transação vai ser uma entidade) podia ser tipo um atriburo que saria true or false(?)


# Esquema ER e planeamento da DB 


## Conjuntos de entidades



- Session
    - SessionID
    - SessionName
    - TimeSlot
    - Lots
    - Participants
    - Licitador
    - OrganizationID - isto para o MER e para o DER não é preciso, só depois no MR. Há mais iguais, vou colocar "#" onde for.
    - State (pode ser um campo calculado)
    - Local (possivel entidade)


- ItemTransaction
    - ID
    - ItemID
    - LotID
    - Date
    - Price
    - SoldInBid (boolean)

- Organization
    - OrganizationID
    - Name
	- Nº de sessões realizadas (atributo calculado) ?

- Item
    - Name
    - Price
    - CategoryID #
    - State (vendido ou nao, pode referenciar uma tabela de states) 
    - Lot ID #
	
- Lot
    - Name
    - ID
    - SessionID#
    
- Bid
    - Price
    - ParticipantID #
    - Date
    - SessionID #
    - LotID #

- MuscleCategory **recursive relation**
    - CategoryID
    - CategoryName
    - ParentCategory (criar uma relação recursiva, exemplo: "tricep" -> parentID (id da categoria de "braço")) 
	Aqui a categoria e subcategoria acho que podiamos colocar por exemplo MuscleGroup e Muscle e utilizar uma entidade categoria para outra coisa tipo por exemplo o tipo de 
	máquina[plateLoaded, Selectorized(com pino para selecionar o peso),  por exemplo! e depois freeWeights se também se for licitar halteres
	e anilhas]

- MachineCategory
    - CategoryOption Example:
        - Freeweight
        - Plated
        - Plated
        - Hydraulic/Pneumatic Resistance e cardio
        - Other Equipment

- Pessoa **generalization**
    - PessoaID
    - Nome
    - Etc..

- Participants **generalization with Person**
    - ParticipantID
    - Name
    - Address
    - BirthDate
    - etc..
    

- Licitadores **generalization with Person**
    - PessoaID


- Sales
    - SaleID
    - SessionID
    - LotID ??? #
    - State
    - BuyerID #
	Isto seria uma entidade venda? para representar quando um item/lote é vendido

- TimeSlot
    - TimeSlotID 
    - DateDay
    - StartTime
    - EndTime


## Conjuntos de relacionamentos




- Session_TimeSlot
    - Session faz referencia a TimeSlot
    - Sessão "occore" num timeslot

    
- Session_Organization
    - Session faz referencia a Organization
    - Sessão é "gerida" por uma Organização
- Item_Lote
    - Item faz referencia a Lot
- Item_Category
    - Item faz referencia a Category
- Lote_Session
    - Lote faz referencia a Session
- Bid_Session
    - Bid faz referencia a Sessiom
- Bid_Participant
    - Bid faz referencia a Participant
- Bid_Lot
    - Bid faz referencia a Lot
- Category_Category
    - Category faz referencia a Category (sub-categorias)



- Participant_Session ????
    - COMO FAZER ESTA REFERENCIA?? CRIAR UMA NOVA ENTIDADE PARA O LEILAO (ITEMS/LOTS E ESTADO) E OUTRA QUE É MESMO A SESSION (QUANDO, PARTICIPANTES, QUE LEILAO) ? 
	Em relação a isto, primeiro, um leilão vai ter várias sessões certo? depois uma sessão vai ter vários lotes e cada lote vai ter um ou mais itens? 
	Agora, uma pessoa que vá participar num leilão, pode só participar numa das sessões do leilão certo? e se for a uma sessão vai ter que ir a todos os lotes?
- Sales_Session
    - Sales faz referencia com Session
- Sales_Lot
    - Sales faz referencia a Lot
- Sales_Participant
    - Sales faz referencia a participante (quem compra)
	Aqui uma sale vai se relacionar com um lote e um participante (relacionamneto triplo?!) mas não sei se vai relacionar com sessão
	

# Outras questões #
 A bid como seria colocada? estava a pensar se era necessário ser uma entidade porque nãp sei que atributos próprios vai ter sem ser o preço (n sei se faz sentido ter data)
 A única solução que estou a ver seria ser um atributo do relacionamento entre participante e LOT 


## Ternario

    Session

Sale - Lot - Participante 


# Todo

1. Descrever infraestrutura e objetivo
2. Descrever por verbos e substantivos cada relação
3. Descrever indices estatisticos
4. Criar diagrama MER, DER
5. Criar MR
 
## Feedback / Questões

Abaixo o que fiz ou temos de fazer

#### Entidades

**Bid** : Concordo com entidade associativa, faltava os seus atributos como preço e quando foi feita.
**Organization**: Number of sessions held, nao vejo ser um atributo mas sim um dado estatistico (contar quantas vezes existe em uma session)
**Lot**: 
    - Name é do tipo "Multivaluated", o lote apenas têm um nome. Deve ser "normal"
    - Penso que podemos adicionar um atributo "price", a base será sempre a soma de todos os items.. mas imagina que eu quero chegar lá e manualmente trocar o preço (desconto, ou o que for). Assim teriamos essa possibiliade
    - Adicionei um novo atributo "state", para saber se o lote já foi vendido (uma vez que o state lote seja atualizado, todos os itens também o devem ser se necessário)

**Session_Lot**: Nova entidade associativa para representar ligação entre um lote e sessão. com esta entidade podemos ter um lote em várias sessões (caso não venda)
#### Relações

**Session_Lot**: Adicionada
**Item_Lot**: Troquei para que 1 Lot necessita obrigatoriamente de 1 Item
**Bid_Session**: Bid apenas para 1 session & Session pode ou nao ter bid
**Aucioneer_Lot**: Removi, poiis um auctioneer deve estar ligado a sessão.
**Aucioneer_Session**: Adicionei
**Transaction_Lot**: Trocada para Transaction_Bid, pois uma transacao ocorre a partir de uma bid, e a mesma ja diz qual o lot a que pertence
**Transaction_Bid**: Adicionado

**!participant_session!**: Como fizeste, uma pessoa é apenas participante de um Leilão se fizer um Bid?? Sim pode ser uma possibilidade

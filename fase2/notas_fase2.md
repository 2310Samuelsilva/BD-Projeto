

# Mudancas

- SessionLot para nao ter chave primaria unica mas sim composta
- Adicionado createdAt e updatedAt em todas as tabelas para manter estado
- Trocada coluna "bidPrice" para "bidValue"
- Melhorados os nomes dos atrbutos da tabela ItemHistory


# Duvidas / melhorias

- Precisamos da tabela MUSCULECATEGORY_ITEM? Nao esta definida no modelo relacional mas nao na lista de entidades, nao penso que seja necessario pois a relação é 1:N podemos fazer o item apontar 
- Melhorar os acronimos antes do nome dos atrivutos, de momento um mix entre acronimo "orgXXX" ou nome completo "personXXX". No enunciado diz para utilizarmos acronimos portanto podemos encontrar acronimos fixes para cada tabela.
- Tabela SESSION.. "SESSION" é uma palavra reservada do MySQL portanto acho que podemos mudar o nome da tabela. Senao é sempre necessario utilizar `` a volta.
- Atributos do tipo "SET" como condition, state, etc.. : Devemos predefinir os tipos (como está de momento), criar novas tabelas?
- Refacor no nome dos atributos para serem mais simples
- Validar e adicionar restrições necessárias a colunas das tabelas


# Para fazer


- Alterar relatorio para ter todos os atributos conforme as tabelas, nomes de tabelas, etc..
- Relatorio trocar relacao Item_Lot (1: N) para N:M ou remover

Do enunciado:

- Ponto 1.2 
    - Views: Estao definidas algumas ideias para views, é implementar ou ver outras para fazer
    - Procedures
    - Functions
    - Triggers

- Ponto 1.3 (Ponto 3.)
- Ponto 1.4 (Ponto 5.)
- Ponto 1.5
- Triggers e testes

- Acrescentar info ao Relatorio



## 05/06
- Create.sql
- Populate.sql ()
    - Criar as procedures necessarias e as do ponto 4 do enunciado
- Queries.sql (3.)
- Results.sql (4.)
- Remocao de dados (5.)
- Resto
    




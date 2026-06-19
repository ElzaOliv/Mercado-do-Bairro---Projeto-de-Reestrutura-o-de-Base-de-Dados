-- ============================================================
-- SCRIPT DE RESOLUÇÃO DAS 20 PERGUNTAS
-- Mercado do Bairro
-- Tabelas: Lojas, Fornecedores, Categorias, Produtos,
--          Funcionarios, Clientes_Fidelidade, Transacoes,
--          Linhas_Venda, Linhas_venda_transacao
-- ============================================================

-- Pergunta 1 — Produtos cujo nome começa com "Leite" ou contém "Integral"
SELECT *
FROM Produtos
WHERE nome_produto LIKE 'Leite%'
   OR nome_produto LIKE '%Integral%';

-- Pergunta 2 — Linhas de venda com quantidade > 2 em transações do turno Manhã
SELECT *
FROM Linhas_Venda
WHERE quantidade_vendida > 2
  AND id IN (
      SELECT id_linha_venda FROM Linhas_venda_transacao
      WHERE id_transacao IN (
          SELECT id FROM Transacoes WHERE turno = 'Manha'));

-- Pergunta 3 — Fornecedores com nome "Panrico" ou "Lactogal"
SELECT *
FROM Fornecedores
WHERE nome_fornecedor LIKE '%Panrico%'
   OR nome_fornecedor LIKE '%Lactogal%';

-- Pergunta 4 — Produtos entre 1.00€ e 10.00€ excluindo categoria Limpeza
SELECT *
FROM Produtos
WHERE preco_unitario BETWEEN 1.00 AND 10.00
  AND id_categoria <> (SELECT id FROM Categorias WHERE nome_categoria = 'Limpeza');

-- Pergunta 5 — INNER JOIN: IdTransacao, DataVenda, CodProduto, QuantidadeVendida
SELECT t.id_transacao, t.data_venda, p.cod_produto, lv.quantidade_vendida
FROM Transacoes t
INNER JOIN Linhas_venda_transacao lvt ON t.id = lvt.id_transacao
INNER JOIN Linhas_Venda lv ON lvt.id_linha_venda = lv.id
INNER JOIN Produtos p ON lv.id_produto = p.id;

-- Pergunta 6 — LEFT JOIN: clientes e datas de compras (NULL se sem compras)
SELECT cf.num_cartao_cliente, cf.nome_cliente_fidelidade, t.data_venda
FROM Clientes_Fidelidade cf
LEFT JOIN Transacoes t ON cf.id = t.id_cliente;

-- Pergunta 7 — Simulação RIGHT JOIN: todos os funcionários e as suas transações
SELECT f.cod_funcionario, f.nome_funcionario_caixa, t.id_transacao
FROM Funcionarios f
LEFT JOIN Transacoes t ON f.id = t.id_funcionario;

-- Pergunta 8 — Simulação FULL JOIN: produtos e fornecedores
SELECT p.cod_produto, p.nome_produto, f.cod_fornecedor, f.nome_fornecedor
FROM Produtos p
LEFT JOIN Fornecedores f ON p.id_fornecedor = f.id
UNION
SELECT p.cod_produto, p.nome_produto, f.cod_fornecedor, f.nome_fornecedor
FROM Fornecedores f
LEFT JOIN Produtos p ON f.id = p.id_fornecedor;

-- Pergunta 9 — Quantidade total vendida por categoria
SELECT c.nome_categoria, SUM(lv.quantidade_vendida) AS total_vendido
FROM Linhas_Venda lv
JOIN Produtos p ON lv.id_produto = p.id
JOIN Categorias c ON p.id_categoria = c.id
GROUP BY c.nome_categoria;

-- Pergunta 10 — Valor total faturado por transação
SELECT t.id_transacao, SUM(lv.quantidade_vendida * p.preco_unitario) AS total_faturado
FROM Transacoes t
JOIN Linhas_venda_transacao lvt ON t.id = lvt.id_transacao
JOIN Linhas_Venda lv ON lvt.id_linha_venda = lv.id
JOIN Produtos p ON lv.id_produto = p.id
GROUP BY t.id_transacao;

-- Pergunta 11 — Média de preços por categoria onde média > 2.00€
SELECT c.nome_categoria, AVG(p.preco_unitario) AS media_preco
FROM Produtos p
JOIN Categorias c ON p.id_categoria = c.id
GROUP BY c.nome_categoria
HAVING AVG(p.preco_unitario) > 2.00;

-- Pergunta 12 — Pontos máximos acumulados num cartão de fidelidade
SELECT MAX(pontos_acumulados) AS max_pontos
FROM Clientes_Fidelidade;

-- Pergunta 13 — INSERT: nova loja e novo funcionário
INSERT INTO Lojas (cod_loja, localidade_loja)
VALUES ('L05', 'Barreiro');

INSERT INTO Funcionarios (cod_funcionario, nome_funcionario_caixa, id_loja)
VALUES ('CX11', 'Ana Pereira', 5);

-- Pergunta 14 — UPDATE: TaxaIVA = 23 para produtos da categoria Limpeza
UPDATE Produtos
SET taxa_iva = 23
WHERE id_categoria = (SELECT id FROM Categorias WHERE nome_categoria = 'Limpeza');

-- Pergunta 15 — DELETE: remover uma linha específica de venda
DELETE FROM Linhas_Venda
WHERE id = 3;

-- Pergunta 16 — DDL da tabela Produtos com Chave Primária
CREATE TABLE Produtos (
    id             INTEGER PRIMARY KEY,
    cod_produto    TEXT NOT NULL,
    nome_produto   TEXT NOT NULL,
    preco_unitario DECIMAL,
    taxa_iva       INTEGER,
    id_categoria   INTEGER,
    id_fornecedor  INTEGER,
    FOREIGN KEY (id_categoria)  REFERENCES Categorias(id),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id)
);

-- Pergunta 17 — Chave Primária Composta na tabela Linhas_venda_transacao
CREATE TABLE Linhas_venda_transacao (
    id_linha_venda  INTEGER NOT NULL,
    id_transacao    INTEGER NOT NULL,
    PRIMARY KEY (id_linha_venda, id_transacao),
    FOREIGN KEY (id_linha_venda) REFERENCES Linhas_Venda(id),
    FOREIGN KEY (id_transacao)   REFERENCES Transacoes(id)
);

-- Pergunta 18 — CHECK CONSTRAINT: quantidade_vendida > 0
CREATE TABLE Linhas_Venda (
    id                 INTEGER PRIMARY KEY,
    id_produto         INTEGER NOT NULL,
    quantidade_vendida INTEGER NOT NULL CHECK (quantidade_vendida > 0),
    FOREIGN KEY (id_produto) REFERENCES Produtos(id)
);

-- Pergunta 19 — VIEW v_Faturacao_Por_Loja
CREATE VIEW v_Faturacao_Por_Loja AS
SELECT l.cod_loja, l.localidade_loja,
       SUM(lv.quantidade_vendida * p.preco_unitario) AS total_faturado
FROM Lojas l
JOIN Transacoes t        ON l.id = t.id_loja
JOIN Linhas_venda_transacao lvt ON t.id = lvt.id_transacao
JOIN Linhas_Venda lv     ON lvt.id_linha_venda = lv.id
JOIN Produtos p          ON lv.id_produto = p.id
GROUP BY l.cod_loja, l.localidade_loja;

-- Pergunta 20 — VIEW v_Clientes_Fidelidade_Ativos
CREATE VIEW v_Clientes_Fidelidade_Ativos AS
SELECT cf.num_cartao_cliente, cf.nome_cliente_fidelidade,
       COUNT(t.id) AS total_compras
FROM Clientes_Fidelidade cf
JOIN Transacoes t ON cf.id = t.id_cliente
GROUP BY cf.num_cartao_cliente, cf.nome_cliente_fidelidade;

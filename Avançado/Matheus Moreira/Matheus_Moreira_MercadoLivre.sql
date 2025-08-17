
-- MercadoLivre (versão simples) - PostgreSQL
-- Execute este script dentro do banco já criado no pgAdmin: MercadoLivre
-- Dica: Se quiser reexecutar, este script limpa e recria as tabelas.

-- Limpeza (ordem reversa para evitar problemas de FK)
DROP TABLE IF EXISTS favoritos       CASCADE;
DROP TABLE IF EXISTS itens_compra    CASCADE;
DROP TABLE IF EXISTS compras         CASCADE;
DROP TABLE IF EXISTS produtos        CASCADE;
DROP TABLE IF EXISTS enderecos       CASCADE;
DROP TABLE IF EXISTS entregadores    CASCADE;
DROP TABLE IF EXISTS clientes        CASCADE;
DROP TABLE IF EXISTS vendedores      CASCADE;

-- =====================
-- Tabelas principais
-- =====================

CREATE TABLE vendedores (
  id         SERIAL PRIMARY KEY,
  nome       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  cnpj       TEXT UNIQUE,
  telefone   TEXT,
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE clientes (
  id         SERIAL PRIMARY KEY,
  nome       TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  cpf        TEXT UNIQUE,
  telefone   TEXT,
  criado_em  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE entregadores (
  id            SERIAL PRIMARY KEY,
  nome          TEXT NOT NULL,
  documento     TEXT UNIQUE,
  placa_veiculo TEXT,
  telefone      TEXT,
  criado_em     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Um endereço pertence a um cliente OU a um vendedor
CREATE TABLE enderecos (
  id          SERIAL PRIMARY KEY,
  logradouro  TEXT NOT NULL,
  numero      TEXT NOT NULL,
  complemento TEXT,
  bairro      TEXT,
  cidade      TEXT NOT NULL,
  estado      CHAR(2) NOT NULL,
  cep         TEXT NOT NULL,
  referencia  TEXT,
  cliente_id  INTEGER REFERENCES clientes(id)  ON DELETE CASCADE,
  vendedor_id INTEGER REFERENCES vendedores(id) ON DELETE CASCADE,
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT enderecos_um_dono CHECK (
    (cliente_id IS NOT NULL AND vendedor_id IS NULL) OR
    (cliente_id IS NULL AND vendedor_id IS NOT NULL)
  )
);

-- Um produto pertence a 1 vendedor; aparece em várias compras via itens_compra
CREATE TABLE produtos (
  id          SERIAL PRIMARY KEY,
  vendedor_id INTEGER NOT NULL REFERENCES vendedores(id) ON DELETE RESTRICT,
  nome        TEXT NOT NULL,
  descricao   TEXT,
  preco       NUMERIC(10,2) NOT NULL CHECK (preco >= 0),
  estoque     INTEGER NOT NULL DEFAULT 0 CHECK (estoque >= 0),
  ativo       BOOLEAN NOT NULL DEFAULT TRUE,
  criado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Uma compra pertence a 1 cliente; pode ter 1 entregador e 1 endereço de entrega
CREATE TABLE compras (
  id                   SERIAL PRIMARY KEY,
  cliente_id           INTEGER NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
  entregador_id        INTEGER REFERENCES entregadores(id) ON DELETE SET NULL,
  endereco_entrega_id  INTEGER REFERENCES enderecos(id) ON DELETE SET NULL,
  status               TEXT NOT NULL CHECK (status IN ('CRIADA','PAGA','ENVIADA','ENTREGUE','CANCELADA')) DEFAULT 'CRIADA',
  valor_total          NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (valor_total >= 0),
  criado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Itens (N-N: compras x produtos) com atributos próprios
CREATE TABLE itens_compra (
  compra_id      INTEGER NOT NULL REFERENCES compras(id)  ON DELETE CASCADE,
  produto_id     INTEGER NOT NULL REFERENCES produtos(id) ON DELETE RESTRICT,
  quantidade     INTEGER NOT NULL CHECK (quantidade > 0),
  preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0),
  PRIMARY KEY (compra_id, produto_id)
);

-- Favoritos (N-N: clientes x produtos)
CREATE TABLE favoritos (
  cliente_id    INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  produto_id    INTEGER NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
  favoritado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (cliente_id, produto_id)
);

-- =====================
-- Dados de exemplo
-- =====================

-- Vendedores (ids esperados: 1,2)
INSERT INTO vendedores (nome, email, cnpj, telefone) VALUES
('Loja Tech Prime',      'contato@techprime.com',      '12345678000190', '+55 11 4000-1000'),
('Casa das Utilidades',  'vendas@utilidadescasa.com',  '98765432000155', '+55 21 4000-2000');

-- Clientes (ids esperados: 1,2,3)
INSERT INTO clientes (nome, email, cpf, telefone) VALUES
('Matheus Moreira', 'matheus@example.com', '21728468051', '+55 85 99999-0001'),
('Julia Rocha',     'julia@example.com',   '12345678901', '+55 85 99999-0002'),
('Vagner Lima',     'vagner@example.com',  '98765432100', '+55 85 99999-0003');

-- Entregadores (ids esperados: 1,2)
INSERT INTO entregadores (nome, documento, placa_veiculo, telefone) VALUES
('Rápido Express',   'TRANSP001', 'ABC1D23', '+55 85 98888-1111'),
('Correios Motoboy', 'TRANSP002', 'XYZ9Z99', '+55 85 97777-2222');

-- Endereços (ids esperados: 1..5)
-- Clientes
INSERT INTO enderecos (logradouro, numero, complemento, bairro, cidade, estado, cep, referencia, cliente_id, vendedor_id) VALUES
('Rua das Flores', '123', 'Apto 202', 'Centro',   'Fortaleza', 'CE', '60000-000', 'Próx. à praça', 1, NULL),
('Av. Beira Mar',  '4500', NULL,       'Meireles', 'Fortaleza', 'CE', '60165-121', 'Cobertura',     1, NULL),
('Rua das Acácias','50',  'Casa',      'Aldeota',  'Fortaleza', 'CE', '60120-340', 'Portão azul',   2, NULL);
-- Vendedores
INSERT INTO enderecos (logradouro, numero, complemento, bairro, cidade, estado, cep, referencia, cliente_id, vendedor_id) VALUES
('Rua do Comércio', '500', 'Sala 12',  'Centro', 'São Paulo',     'SP', '01010-010', 'Ed. Empresarial', NULL, 1),
('Av. Brasil',      '1000', NULL,      'Centro', 'Rio de Janeiro','RJ', '20040-000', 'Loja 3',         NULL, 2);

-- Produtos (ids esperados: 1..5)
INSERT INTO produtos (vendedor_id, nome, descricao, preco, estoque, ativo) VALUES
(1, 'Fone Bluetooth',    'Fone sem fio com cancelamento de ruído', 199.90,  50, TRUE),
(1, 'Teclado Mecânico',  'Switch blue, ABNT2, RGB',                399.90,  20, TRUE),
(2, 'Garrafa Térmica 1L','Inox, mantém quente por 12h',             89.90, 100, TRUE),
(2, 'Aspirador Portátil','AC bivolt, filtro HEPA',                 249.90,  12, TRUE),
(1, 'Cabo USB-C 1m',     'Suporta carregamento rápido',             29.90, 200, TRUE);

-- Compras (ids esperados: 1..3)
INSERT INTO compras (cliente_id, entregador_id, endereco_entrega_id, status, valor_total) VALUES
(1, 1, 1, 'ENVIADA', 259.70),
(2, 2, 3, 'PAGA',    339.80),
(1, 2, 2, 'CRIADA',  399.90);

-- Itens por compra
-- Compra 1: Fone x1 (199.90) + Cabo x2 (29.90)
INSERT INTO itens_compra (compra_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 199.90),
(1, 5, 2,  29.90);

-- Compra 2: Garrafa x1 (89.90) + Aspirador x1 (249.90)
INSERT INTO itens_compra (compra_id, produto_id, quantidade, preco_unitario) VALUES
(2, 3, 1,  89.90),
(2, 4, 1, 249.90);

-- Compra 3: Teclado x1 (399.90)
INSERT INTO itens_compra (compra_id, produto_id, quantidade, preco_unitario) VALUES
(3, 2, 1, 399.90);

-- Favoritos
INSERT INTO favoritos (cliente_id, produto_id) VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 5),
(3, 4);

-- Consultas rápidas (opcional):
-- SELECT * FROM vendedores;
-- SELECT * FROM clientes;
-- SELECT * FROM entregadores;
-- SELECT * FROM enderecos;
-- SELECT * FROM produtos;
-- SELECT * FROM compras;
-- SELECT * FROM itens_compra;
-- SELECT * FROM favoritos;

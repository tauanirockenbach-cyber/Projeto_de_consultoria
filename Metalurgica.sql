-- ============================================================
--  METALÚRGICA YZ — Banco de Dados MySQL
--  Projetos SST & Sustentabilidade
--  Execute: mysql -u root -p < banco_metalurgica_yz.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS metalurgica_yz CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE metalurgica_yz;

-- ============================================================
--  TABELA: projetos
-- ============================================================
CREATE TABLE IF NOT EXISTS projetos (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    codigo      VARCHAR(20)  NOT NULL UNIQUE,
    area        VARCHAR(100) NOT NULL,
    problema    TEXT         NOT NULL,
    solucao     VARCHAR(200) NOT NULL,
    descricao   TEXT,
    orcamento   DECIMAL(10,2) NOT NULL DEFAULT 0,
    status      ENUM('Em Análise','Aprovado','Em Execução','Concluído','Cancelado') DEFAULT 'Em Análise',
    prazo_meses INT,
    responsavel VARCHAR(100),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
--  TABELA: itens_investimento
-- ============================================================
CREATE TABLE IF NOT EXISTS itens_investimento (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id  INT NOT NULL,
    descricao   VARCHAR(200) NOT NULL,
    valor       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (projeto_id) REFERENCES projetos(id) ON DELETE CASCADE
);

-- ============================================================
--  TABELA: kpis
-- ============================================================
CREATE TABLE IF NOT EXISTS kpis (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id  INT NOT NULL,
    indicador   VARCHAR(200) NOT NULL,
    meta        VARCHAR(100) NOT NULL,
    realizado   VARCHAR(100),
    status      ENUM('Aguardando','No Prazo','Atrasado','Atingido') DEFAULT 'Aguardando',
    FOREIGN KEY (projeto_id) REFERENCES projetos(id) ON DELETE CASCADE
);

-- ============================================================
--  TABELA: normas_legislacao
-- ============================================================
CREATE TABLE IF NOT EXISTS normas_legislacao (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    projeto_id  INT NOT NULL,
    norma       VARCHAR(100) NOT NULL,
    descricao   TEXT,
    FOREIGN KEY (projeto_id) REFERENCES projetos(id) ON DELETE CASCADE
);

-- ============================================================
--  TABELA: usuarios (para o front-end)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    perfil      ENUM('Admin','Gestor','Operador') DEFAULT 'Operador',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  DADOS: Projetos
-- ============================================================
INSERT INTO projetos (codigo, area, problema, solucao, descricao, orcamento, status, prazo_meses, responsavel) VALUES
('SGR-001',
 'Meio Ambiente — Gestão de Resíduos',
 'Falhas graves na gestão de resíduos industriais. Ausência de rastreabilidade desde a geração até a destinação final, expondo a empresa a riscos ambientais e legais, especialmente para resíduos Classe I (perigosos).',
 'Sistema Digital de Gestão de Resíduos (SGR) com Rastreabilidade',
 'Software SGR com cadastro, classificação, pesagem e rastreamento de todos os resíduos via QR Code. Dashboard com indicadores de destinação. Contratos formalizados com empresas para resíduos Classe I.',
 16000.00, 'Em Análise', 3, 'Equipe Ambiental'),

('MED-002',
 'Eficiência de Recursos — Água e Energia',
 'Consumo ineficiente de água e energia sem instrumentação nem monitoramento setorizado. Uso de mangueiras abertas para limpeza e processos sem controle de ciclo.',
 'Medidores Setorizados + Protocolo de Uso Racional',
 'Instalação de hidrômetros digitais em cada ponto de uso. Sistema de dashboard para registro e análise mensal do consumo. Substituição de mangueiras abertas por lavadoras de alta pressão.',
 7500.00, 'Em Análise', 3, 'Equipe Técnica'),

('SST-003',
 'Cultura Organizacional — Segurança e Sustentabilidade',
 'Cultura interna que não prioriza adequadamente a segurança e a sustentabilidade. Colaboradores não se engajam nas iniciativas de SST, inspeções realizadas por obrigação.',
 'Plataforma Digital Safety Score com Gamificação',
 'App/sistema web onde colaboradores registram inspeções, reportam quase-acidentes e acumulam pontos por conformidade. Ranking por setor com premiação trimestral.',
 12000.00, 'Em Análise', 2, 'Equipe SST');

-- ============================================================
--  DADOS: Itens de Investimento
-- ============================================================
INSERT INTO itens_investimento (projeto_id, descricao, valor) VALUES
-- SGR
(1, 'Desenvolvimento/implantação software SGR', 8000.00),
(1, 'Infraestrutura QR Code (etiquetas, leitores)', 2500.00),
(1, 'Integração com balança eletrônica', 1500.00),
(1, 'Formalização contratos Classe I (apoio ambiental)', 2000.00),
(1, 'Treinamento da equipe ambiental e operacional', 2000.00),
-- Medidores
(2, 'Hidrômetros digitais setorizados (8 pontos)', 2800.00),
(2, 'Medidores de energia elétrica (6 setores)', 2400.00),
(2, 'Lavadoras de alta pressão (substituição)', 1200.00),
(2, 'Configuração planilha digital e dashboard', 600.00),
(2, 'Treinamento e implantação do protocolo', 500.00),
-- Safety Score
(3, 'Desenvolvimento do app/plataforma Safety Score', 6500.00),
(3, 'Painéis digitais de ranking (monitor por setor)', 2000.00),
(3, 'Configuração do sistema de gamificação e badges', 1500.00),
(3, 'Budget de premiação trimestral (inicial)', 1000.00),
(3, 'Treinamento e lançamento interno', 1000.00);

-- ============================================================
--  DADOS: KPIs
-- ============================================================
INSERT INTO kpis (projeto_id, indicador, meta, status) VALUES
-- SGR
(1, 'Resíduos rastreados digitalmente', '100% do volume', 'Aguardando'),
(1, 'Tempo de emissão do MTR', '< 1 hora', 'Aguardando'),
(1, 'Não conformidades ambientais', 'Zero/mês', 'Aguardando'),
(1, 'Taxa de reciclagem (Classe II-A)', '> 70%', 'Aguardando'),
(1, 'Relatórios no prazo legal', '100%', 'Aguardando'),
-- Medidores
(2, 'Redução consumo de água', '-20% em 12 meses', 'Aguardando'),
(2, 'Redução consumo de energia', '-15% em 12 meses', 'Aguardando'),
(2, 'Setores com medição instalada', '100% até mês 3', 'Aguardando'),
(2, 'Relatórios mensais no prazo', '100%', 'Aguardando'),
(2, 'Alertas com ação corretiva', '> 90%', 'Aguardando'),
-- Safety Score
(3, 'Adesão ao app (colaboradores ativos)', '> 80% da equipe', 'Aguardando'),
(3, 'Inspeções registradas/mês', '> 90% programadas', 'Aguardando'),
(3, 'Quase-acidentes reportados/mês', '+20% vs. manual', 'Aguardando'),
(3, 'Safety Score médio da fábrica', 'Crescimento trimestral', 'Aguardando'),
(3, 'Setores na premiação', '100% elegíveis', 'Aguardando');

-- ============================================================
--  DADOS: Normas e Legislação
-- ============================================================
INSERT INTO normas_legislacao (projeto_id, norma, descricao) VALUES
-- SGR
(1, 'Lei 12.305/2010 — PNRS', 'Responsabilidade compartilhada e logística reversa'),
(1, 'ABNT NBR 10.004', 'Classificação de Resíduos: Classe I (perigosos) e Classe II (não perigosos)'),
(1, 'Resolução CONAMA 275/2001', 'Padrões de coleta seletiva e identificação de resíduos'),
(1, 'Legislação estadual SC', 'Licenciamento ambiental industrial de Santa Catarina'),
-- Medidores
(2, 'NBR ISO 14001', 'Sistema de Gestão Ambiental: gestão de aspectos e impactos ambientais'),
(2, 'Lei 9.433/1997 — PNRH', 'Política Nacional de Recursos Hídricos: uso racional e eficiente'),
(2, 'Resolução ANEEL', 'Eficiência Energética: programas de redução de consumo em indústrias'),
(2, 'ABNT NBR 5410', 'Instalações Elétricas de Baixa Tensão: segurança nas medições'),
-- Safety Score
(3, 'NR-1', 'Disposições Gerais: obrigatoriedade do PGR e participação dos trabalhadores'),
(3, 'NR-5 — CIPA', 'Envolvimento dos colaboradores na prevenção de acidentes'),
(3, 'ISO 45001', 'Sistema de Gestão de SST: cultura de segurança e participação ativa'),
(3, 'NR-9 — PPRA', 'Programa de Prevenção de Riscos Ambientais: base para registros do Safety Score');

-- ============================================================
--  DADOS: Usuário inicial (admin)
-- ============================================================
INSERT INTO usuarios (nome, email, perfil) VALUES
('Administrador YZ', 'admin@metalurgicayz.com.br', 'Admin');

-- ============================================================
--  VIEWS ÚTEIS
-- ============================================================

-- View: resumo financeiro por projeto
CREATE OR REPLACE VIEW vw_resumo_financeiro AS
SELECT
    p.id,
    p.codigo,
    p.area,
    p.solucao,
    p.orcamento,
    p.status,
    COALESCE(SUM(i.valor), 0)   AS total_itens,
    p.orcamento - COALESCE(SUM(i.valor), 0) AS saldo
FROM projetos p
LEFT JOIN itens_investimento i ON i.projeto_id = p.id
GROUP BY p.id;

-- View: total geral
CREATE OR REPLACE VIEW vw_total_geral AS
SELECT
    COUNT(*)         AS total_projetos,
    SUM(orcamento)   AS investimento_total,
    SUM(CASE WHEN status = 'Concluído' THEN 1 ELSE 0 END) AS concluidos
FROM projetos;

-- ============================================================
--  QUERIES DE EXEMPLO
-- ============================================================

-- Todos os projetos com totais
-- SELECT * FROM vw_resumo_financeiro;

-- KPIs por projeto
-- SELECT p.codigo, p.area, k.indicador, k.meta, k.realizado, k.status
-- FROM kpis k JOIN projetos p ON k.projeto_id = p.id;

-- Itens por projeto
-- SELECT p.codigo, i.descricao, i.valor
-- FROM itens_investimento i JOIN projetos p ON i.projeto_id = p.id
-- ORDER BY p.id;